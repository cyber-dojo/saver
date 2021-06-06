require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'options_checker'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

# 1. Now uses git repo to store kata
# 2. event.json has been dropped
# 3. event_summary.json is now called events.json and contains a json array
# 4. entries in events.json have strictly sequential indexes
# TODO: saver outages are recorded in events_summary.json
# TODO: options.json holds the options
# TODO: option_set is recorded as an event
# TODO: polyfill events_summary so all entries have an 'event' key

class Kata_v2

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest, options)
    fail_unless_known_options(options)
    manifest.merge!(options) # TODO: revisit...
    manifest['version'] = 2
    manifest['created'] = time.now
    events = [{
      'index' => 0,
      'event' => 'created',
      'time'  => manifest['created']
    }]
    files = manifest.delete('visible_files')
    options.merge!(default_options)

    # IdGenerator makes the kata dir, eg /cyber-dojo/katas/Rl/mR/cV
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    disk.assert_all([
      disk.file_create_command(manifest_filename(id), json_pretty(manifest)),
      disk.file_create_command(options_filename(id), json_pretty(options)),
      disk.file_create_command(events_filename(id), json_pretty(events)),
      disk.file_create_command(readme_filename(id), readme)
    ])

    files_dir = "#{kata_dir(id)}/files"
    write_files(disk, files_dir, content_of(files))

    shell.assert_cd_exec("/#{disk.root_dir}/#{kata_dir(id)}", [
      "git init --quiet",
      "git config user.name '#{id}'",
      "git config user.email '#{id}@cyber-dojo.org'",
      "git add .",
      "git commit --all --allow-empty --message '0 kata creation' --quiet",
      "git tag 0 HEAD",
      "git branch -m master main"
    ])

    id
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    result = read_manifest(disk, id)
    polyfill_manifest_defaults(result)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = read_events(disk, id)
    #TODO: polyfill_events_defaults(result)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    result = { "files" => {} }
    index = index.to_i
    if index < 0
      index = events(id)[index]['index']
    end

    truncations = nil
    kata_dir = '/' + disk.root_dir + kata_id_path(id)  # '/cyber-dojo/katas/R2/mR/cV
    tar_file = shell.assert_cd_exec(kata_dir, "git archive --format=tar #{index}")
    reader = TarFile::Reader.new(tar_file)
    reader.files.each do |filename, content|
      if filename[-1] === '/' # dir marker
        next
      elsif filename.start_with?("files/")
        result["files"][filename["files/".size..-1]] = {
          "content" => content
        }
      elsif ["stdout", "stderr"].include?(filename)
        result[filename] = {
          "content" => content
        }
      elsif filename === "status"
        result["status"] = content
      elsif filename === "events.json"
        event = json_parse(content).last
        result.merge!(event)
      elsif filename === "truncations.json"
        truncations = json_parse(content)
      end
    end

    if result.has_key?('stdout')
      result['stdout']['truncated'] = truncations['stdout']
      result['stderr']['truncated'] = truncations['stderr']
    end

    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event_batch(ids, indexes)
    # TODO: loop over event(id, index) above
    json = {}

    commands = []
    (0...ids.size).each do |i|
      id = ids[i]
      index = indexes[i]
      commands << events_file_read_command(id, index) # TODO: drop
    end
    results = disk.assert_all(commands)

    (0...ids.size).each do |i|
      j = json_parse(results[i])
      id = ids[i]
      index = indexes[i]
      json[id] ||= {}
      json[id][index.to_s] = j
    end

    json
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    git_commit_tag(id, index, files, stdout, stderr, status, summary)
  end

  def predicted_right(id, index, files, stdout, stderr, status, summary)
    git_commit_tag(id, index, files, stdout, stderr, status, summary)
  end

  def predicted_wrong(id, index, files, stdout, stderr, status, summary)
    git_commit_tag(id, index, files, stdout, stderr, status, summary)
  end

  def reverted(id, index, files, stdout, stderr, status, summary)
    git_commit_tag(id, index, files, stdout, stderr, status, summary)
  end

  def checked_out(id, index, files, stdout, stderr, status, summary)
    git_commit_tag(id, index, files, stdout, stderr, status, summary)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def option_get(id, name)
    fail_unless_known_option(name)
    options_read(disk, id)[name]
  end

  def option_set(id, name, value)
    # TODO: use options.json file
    # TODO: commit & ff-merge but do not tag
    fail_unless_known_option(name)
    possibles = (name === 'theme') ? ['dark','light'] : ['on', 'off']
    unless possibles.include?(value)
      fail "Cannot set theme to #{value}, only to one of #{possibles}"
    end
    filename = kata_id_path(id, name)
    result = disk.run_all([
      disk.file_create_command(filename, "\n"+value),
      disk.file_append_command(filename, "\n"+value)
    ])
    result
  end

  private

  include IdPather
  include JsonAdapter
  include OptionsChecker
  include PolyFiller

  # - - - - - - - - - - - - - - - - - - - - - -

  def git_commit_tag(id, index, files, stdout, stderr, status, summary)
    root_dir = '/' + disk.root_dir + kata_dir(id) # /cyber-dojo/katas/R2/mR/cV
    uuid = random.alphanumeric(8)
    tmp_dir = "/tmp/#{uuid}"

    # Make a unique worktree in tmp_dir
    # uuid is now a branch in root_dir's repo
    shell.assert_cd_exec(root_dir, "git worktree add #{tmp_dir}")

    # Read events.json from worktree (and update it) before it is git rm'd
    disk = External::Disk.new(tmp_dir)
    events   = read_events(disk)

    unless index > events.last['index']
      raise "Out of sync event"
    end
    #TODO: Fill in saver outage entries

    summary['index'] = index
    summary['time'] = time.now
    events << summary

    # Remove worktree files we are recreating
    rm_files = "files stdout stderr status truncations.json #{events_filename}"
    shell.assert_cd_exec(tmp_dir, "git rm --ignore-unmatch -r #{rm_files}")

    # Recreate worktree files
    write_files(disk, "files", content_of(files))

    write_files(disk, '', {
      events_filename => json_pretty(events),
      "stdout" => stdout['content'],
      "stderr" => stderr['content'],
      "status" => status.to_s,
      "truncations.json" => json_pretty({
        "stdout" => stdout["truncated"],
        "stderr" => stderr["truncated"]
      })
    })

    message = "'#{index}'" # TODO: better message, eg predicted green got red
    shell.assert_cd_exec(tmp_dir, [
      "git add .",
      "git commit --allow-empty --all --message #{message} --quiet",
    ])

    shell.assert_cd_exec(root_dir, "git merge --ff-only #{uuid}")
    tag_commands = [
      "git tag #{index} HEAD",
    ]
    # TODO: Add tag_commands for saver outages
    shell.assert_cd_exec(root_dir, tag_commands)

  ensure
    shell.assert_cd_exec(root_dir,
      "git worktree remove --force #{uuid}",
      "git branch --delete --force #{uuid}",
      "rm -rf #{tmp_dir}"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def read_manifest(disk, id=nil)
    read_json(disk, manifest_filename(id))
  end

  def read_options(disk, id=nil)
    read_json(disk, events_filename(id))
  end

  def read_events(disk, id=nil)
    read_json(disk, events_filename(id))
  end

  def read_readme(disk, id=nil)
    read(disk, readme_filename(id))
  end

  def read_json(disk, filename)
    json_parse(read(disk, filename))
  end

  def read(disk, filename)
    command = disk.file_read_command(filename)
    disk.assert(command)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_filename(id=nil)
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/manifest.json'
    # eg content ==> { "display_name": "Ruby, MiniTest",...}
    if id.nil?
      "manifest.json"
    else
      kata_id_path(id, manifest_filename)
    end
  end

  def options_filename(id=nil)
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/options.json'
    if id.nil?
      "options.json"
    else
      kata_id_path(id, options_filename)
    end
  end

  def events_filename(id=nil)
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/events.json'
    # eg content ==>
    # [
    #  { "index": 0, ..., "event": "created" },
    #  { "index": 1, ..., "colour": "red"    },
    #  { "index": 2, ..., "colour": "amber"  }
    # ]
    if id.nil?
      "events.json"
    else
      kata_id_path(id, events_filename)
    end
  end

  def readme_filename(id=nil)
    if id.nil?
      "README.md"
    else
      kata_id_path(id, readme_filename)
    end
  end

  def readme
    "README"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def fail_unless_known_option(name)
    unless %w( theme colour predict revert_red revert_amber revert_green ).include?(name)
      fail "Unknown option #{name}"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def write_files(disk, base_dir, files)
    make_dirs(disk, base_dir, files)
    commands = files.each_with_object([]) do |(filename,content),array|
      path = "#{base_dir}/#{filename}"
      array << disk.file_create_command(path, content)
    end
    disk.assert_all(commands)
  end

  def make_dirs(disk, base_dir, files)
    dirs = files.keys.each_with_object([]) do |filename, array|
      path = "#{base_dir}/#{filename}"
      array << File.dirname(path)
    end
    commands = (dirs.uniq.sort - ['/']).map{|dir| disk.dir_make_command(dir)}
    # Eg [ 'a/b', 'a/b/c' ] which must be created in that order
    # because the make_dir command is not idempotent.
    disk.assert_all(commands)
  end

  def make_dir(id, dir)
    path = "#{kata_dir(id)}/#{dir}"
    command = disk.dir_make_command(path)
    disk.run(command)
  end

  def kata_dir(id)
    kata_id_path(id) # relative to /cyber-dojo/ eg '/katas/R2/mR/cV
  end

  def content_of(files)
    files.map{|filename,file| [filename,file['content']]}.to_h
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def default_options
    {
      'theme' => 'light',
      'colour' => 'on',
      'predict' => 'off',
      'revert_red' => 'off',
      'revert_amber' => 'off',
      'revert_green' => 'off',
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def random
    @externals.random
  end

  def shell
    @externals.shell
  end

  def time
    @externals.time
  end

end
