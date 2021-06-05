require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'options_checker'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

# 1. Now uses git repo to store kata
# 2. event.json has been dropped
# 3. events.json is now called events_summary.json
# 4. entries in events_summary.json are strictly sequential
# 5. saver outages are recorded in events_summary.json (TODO)
# 6. option_set is now recorded as an event (TODO)

class Kata_v2

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest, options)
    fail_unless_known_options(options)
    manifest.merge!(options)
    manifest['version'] = 2
    manifest['created'] = time.now
    # IdGenerator makes the root dir, eg /cyber-dojo/katas/Rl/mR/cV
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    event_summary = {
      'index' => 0,
      'time' => manifest['created'],
      'event' => 'created'
    }
    files = manifest.delete('visible_files')

    disk.assert_all([
      manifest_file_create_command(id, json_pretty(manifest)),
      events_summary_file_create_command(id, json_plain(event_summary)),
    ])

    #TODO: Write README.md to /
    make_dir(id, "config")
    #TODO: Write options to config/
    files_dir = "#{kata_dir(id)}/files"
    make_dirs(disk, files_dir, files)
    write_files(disk, files_dir, files)

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
    manifest_src = disk.assert(manifest_file_read_command(id))
    manifest = json_parse(manifest_src)
    polyfill_manifest_defaults(manifest)
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def events(id)
    json_parse('[' + disk.assert(events_summary_file_read_command(id)) + ']')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    result = { "files" => {} }
    index = index.to_i
    if index < 0
      index = events(id)[index]['index']
    end

    kata_dir = '/' + disk.root_dir + kata_id_path(id)  # '/cyber-dojo/katas/R2/mR/cV

    prefix = "files/"
    tar_file = shell.assert_cd_exec(kata_dir, "git archive --format=tar #{index}")
    reader = TarFile::Reader.new(tar_file)
    truncations = nil
    reader.files.each do |filename, content|
      if filename[-1] === '/' # dir marker
        next
      elsif filename.start_with?(prefix)
        result["files"][filename[prefix.size..-1]] = {
          "content" => content
        }
      elsif ["stdout", "stderr"].include?(filename)
        result[filename] = {
          "content" => content
        }
      elsif filename === "status"
        result["status"] = content
      elsif filename === "events_summary.json"
        event = json_parse(content.lines.last)
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
    json = {}

    commands = []
    (0...ids.size).each do |i|
      id = ids[i]
      index = indexes[i]
      commands << event_file_read_command(id, index)
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
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def predicted_right(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def predicted_wrong(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def reverted(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def checked_out(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def option_get(id, name)
    # TODO: use config/ dir
    fail_unless_known_option(name)
    filename = kata_id_path(id, name)
    result = disk.run(disk.file_read_command(filename))
    if result
      result.lines.last
    else
      {
        'theme' => 'light',
        'colour' => 'on',
        'predict' => 'off',
        'revert_red' => 'off',
        'revert_amber' => 'off',
        'revert_green' => 'off',
      }[name]
    end
  end

  def option_set(id, name, value)
    # TODO: use config/ dir
    # TODO: commit & ff-merge
    # TODO: write the new value (dont append to the file)
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

=begin
  def old_universal_append(id, index, files, stdout, stderr, status, summary)
    summary['index'] = index
    summary['time'] = time.now
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    result = disk.assert_all([
      # A failing create_command() ensures the append_command() is not run.
      event_file_create_command(id, index, json_plain(event_n.merge(summary))),
      events_summary_file_append_command(id, ",\n" + json_plain(summary))
    ])
    result
  end
=end

  # - - - - - - - - - - - - - - - - - - - - - -

  def universal_append(id, index, files, stdout, stderr, status, summary)
    uuid = random.alphanumeric(8)
    tmp_dir = "/tmp/#{uuid}"

    src = disk.assert(events_summary_file_read_command(id))
    #events_summary = json_parse('[' + src + ']')
    #TODO:
    #   Check arg-index is not already present as an index in events.json
    #     If it is, raise an exception
    #   Check arg-index is greater than largest index in events.json
    #     If it is, raise an exception

    root_dir = '/' + disk.root_dir + kata_dir(id) # /cyber-dojo/katas/R2/mR/cV
    shell.assert_cd_exec(root_dir, "git worktree add #{tmp_dir}")
    shell.assert_cd_exec(tmp_dir, "git rm -rf .")

    truncations = {
      "stdout" => stdout["truncated"],
      "stderr" => stderr["truncated"]
    }

    disk = External::Disk.new(tmp_dir)
    make_dirs(disk, "files", files)
    write_files(disk, "files", files)

    write_files_commands = []
    summary['index'] = index
    summary['time'] = time.now
    write_files_commands << disk.file_create_command("events_summary.json", src + ",\n" + json_plain(summary))
    write_files_commands << disk.file_create_command("truncations.json", json_pretty(truncations))
    write_files_commands << disk.file_create_command("stdout", stdout['content'])
    write_files_commands << disk.file_create_command("stderr", stderr['content'])
    write_files_commands << disk.file_create_command("status", status.to_s)
    disk.assert_all(write_files_commands)

    message = "'#{index}'" # TODO: better message, eg predicted green got red
    shell.assert_cd_exec(tmp_dir, [
      #"git checkout main -- config/",
      "git checkout main -- manifest.json",
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
  # manifest
  #
  def manifest_file_create_command(id, manifest_src)
    disk.file_create_command(manifest_filename(id), manifest_src)
  end

  def manifest_file_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  def manifest_filename(id)
    kata_id_path(id, 'manifest.json')
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/manifest.json'
    # eg content ==> { "display_name": "Ruby, MiniTest",...}
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events

  def events_summary_file_create_command(id, event0_src)
    disk.file_create_command(events_summary_filename(id), event0_src)
  end

  def events_summary_file_append_command(id, eventN_src)
    disk.file_append_command(events_summary_filename(id), eventN_src)
  end

  def events_summary_file_read_command(id)
    disk.file_read_command(events_summary_filename(id))
  end

  def events_summary_filename(id)
    kata_id_path(id, 'events_summary.json')
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/events_summary.json'
    # eg content ==>
    # { "index": 0, ..., "event": "created" },
    # { "index": 1, ..., "colour": "red"    },
    # { "index": 2, ..., "colour": "amber"  },
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_file_create_command(id, event_src)
    disk.file_create_command(event_filename(id), event_src)
  end

  def event_file_read_command(id)
    disk.file_read_command(event_filename(id))
  end

  def event_filename(id)
    kata_id_path(id, "event.json")
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/event.json'
    # eg content ==>
    # {
    #   "index": 2,
    #   "time": [ 2020,3,27,11,56,7,719235 ],
    #   "duration": 1.064011,
    #   "colour": "amber"
    # }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def fail_unless_known_option(name)
    unless %w( theme colour predict revert_red revert_amber revert_green ).include?(name)
      fail "Unknown option #{name}"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def kata_dir(id)
    # relative to /cyber-dojo/
    kata_id_path(id) # eg '/katas/R2/mR/cV
  end

  def make_dir(id, dir)
    path = "#{kata_dir(id)}/#{dir}"
    command = disk.dir_make_command(path)
    disk.run(command)
  end

  def make_dirs(disk, base_dir, files)
    dirs = []
    files.keys.each do |filename|
      path = "#{base_dir}/files/#{filename}"
      dirs << File.dirname(path)
    end
    commands = []
    dirs.sort.uniq.each do |dir|
      commands << disk.dir_make_command(dir)
    end
    # Not assert_all() because making a dir is not idempotent
    disk.run_all(commands)
  end

  def write_files(disk, base_dir, files)
    create_files_commands = []
    files.each do |filename, file|
      path = "#{base_dir}/#{filename}"
      create_files_commands << disk.file_create_command(path, file["content"])
    end
    disk.assert_all(create_files_commands)
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
