require_relative 'fork'
require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'options'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'
require_relative '../lib/tarfile_reader'
require_relative '../lib/utf8_clean'
require 'base64'
require 'tmpdir'

# 1. Uses git repo to store data
# 2. event.json has been dropped
# 3. event_summary.json is now called events.json and contains a json array
# 4. entries in events.json have strictly sequential indexes
# 5. saver outages are NOT recorded in events.json
# 6. There are new file-create/delete/rename/edit events

# File-events
# In web microservice, whenever:
#   - a new (empty) file is created, file_create is called.
#   - a file is deleted, file_delete is called.
#   - a file is renamed, file_rename is called.
#   - a new file is *selected*, file_edit is called 
#     which catches all changes to individual files.
# Thus events.json could hold, for example
#  0=create, 1=rename, 2=edit, 3=ran-tests, 4=edit, 5=edit, 6=ran-tests
# This means that the index in each event no longer corresponds to
# just the red/amber/green ran-tests events. In the above, there are
# two ran-tests events at indexes 3,6 which would previously have been 1,2
# Because of this, ran_tests2() now returns the 'major_index' which 
# corresponds to the previous red/amber/green index.

class Kata_v2

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    manifest['version'] = 2
    manifest['created'] = time.now
    events = [{
      'index' => 0,
      'event' => 'created',
      'time'  => manifest['created']
    }]
    files = manifest.delete('visible_files')

    # IdGenerator makes the kata dir, eg /cyber-dojo/katas/Rl/mR/cV
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    disk.assert_all([
      disk.file_create_command(manifest_filename(id), json_pretty(manifest)),
      disk.file_create_command(options_filename(id), json_pretty(default_options)),
      disk.file_create_command(events_filename(id), json_pretty(events)),
      disk.file_create_command(readme_filename(id), readme(manifest))
    ])

    files_dir = "#{kata_dir(id)}/files"
    write_files(disk, files_dir, content_of(files))

    shell.assert_cd_exec(repo_dir(id), [
      "git init --quiet",
      "git config user.name '#{id}'",
      "git config user.email '#{id}@cyber-dojo.org'",
      "git add .",
      "git commit --message '0 kata creation' --quiet",
      "git tag 0 HEAD",
      "git branch -m master main"
    ])

    id
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    result = read_manifest(id)
    polyfill_manifest_defaults(result)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = read_events(disk, id)
    result[0]['colour'] = 'create'
    polyfill_major_minor(result)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    index = index.to_i
    all_events = events(id)
    last_index = all_events[-1]['index'] 
    if index > last_index
      raise "Invalid index #{index}"
    end

    if index < 0
      if -index > last_index + 1
        raise "Invalid index #{index}"
      end
      index = all_events[index]['index']
    end

    result = { 'files' => {} }
    truncations = nil

    tar_file = shell.assert_cd_exec(repo_dir(id), "git archive --format=tar #{index}")
    reader = TarFile::Reader.new(tar_file)
    reader.files.each do |filename, content|
      if filename[-1] === '/' # dir marker
        next
      elsif filename.start_with?('files/')
        result['files'][filename['files/'.size..-1]] = { 'content' => content }
      elsif ['stdout', 'stderr'].include?(filename)
        result[filename] = { 'content' => content }
      elsif filename === 'status'
        result['status'] = content
      elsif filename === 'events.json'
        event = json_parse(content)[index]
        result.merge!(event)
      elsif filename === 'truncations.json'
        truncations = json_parse(content)
      end
    end

    if result.has_key?('stdout')
      result['stdout']['truncated'] = truncations['stdout']
      result['stderr']['truncated'] = truncations['stderr']
    end

    if index === 0
      result['stdout'] = { 'content' => '', 'truncated' => false}
      result['stderr'] = { 'content' => '', 'truncated' => false}
      result['status'] = 0
      result['colour'] = 'create'
    end

    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event_batch(ids, indexes)
    ids.zip(indexes).each.with_object({}) do |(id,index),hash|
      hash[id] ||= {}
      hash[id][index.to_s] = event(id, index)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_create(id, index, files, filename)
    # At this point, the (new) filename is NOT present in files.
    index = file_edit(id, index, files)
    files[filename] = { 'content' => '' }
    summary = { 'colour' => 'file_create', 'filename' => filename }
    tag_message = "created file '#{filename}'"
    result = git_commit_tag(id, index, files, summary, tag_message)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_delete(id, index, files, filename)
    # At this point, the (deleted) filename IS present in files.
    index = file_edit(id, index, files)
    files.delete(filename)
    summary = { 'colour' => 'file_delete', 'filename' => filename }
    tag_message = "deleted file '#{filename}'"
    result = git_commit_tag(id, index, files, summary, tag_message)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_rename(id, index, files, old_filename, new_filename)
    # At this point, new_filename is NOT present in files.
    index = file_edit(id, index, files)
    files[new_filename] = files.delete(old_filename)
    summary = { 
      'colour' => 'file_rename', 
      'old_filename' => old_filename,
      'new_filename' => new_filename 
    }
    tag_message = "renamed file #{old_filename} to #{new_filename}"
    result = git_commit_tag(id, index, files, summary, tag_message)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_edit(id, index, files)
    # Creates a saver event if any file has been edited.
    # The timestamp of the file-edit will only be approximate.
    current_files = event(id, index - 1)['files']
    edited_filename = edited_filename(current_files, files)
    if !edited_filename
      return index
    end

    summary = { 'colour' => 'file_edit', 'filename' => edited_filename }
    tag_message = "edited file '#{edited_filename}'"
    result = git_commit_tag(id, index, files, summary, tag_message)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests2(id, index, files, stdout, stderr, status, summary)
    index = file_edit(id, index, files)
    tag_message = "ran tests, no prediction, got #{summary['colour']}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  def predicted_right2(id, index, files, stdout, stderr, status, summary)
    index = file_edit(id, index, files)
    tag_message = "ran tests, predicted #{summary['predicted']}, got #{summary['colour']}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  def predicted_wrong2(id, index, files, stdout, stderr, status, summary)
    index = file_edit(id, index, files)
    tag_message = "ran tests, predicted #{summary['predicted']}, got #{summary['colour']}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  # def reverted2(id, index, files, stdout, stderr, status, summary)
  #   revert = summary['revert']
  #   info = json_plain({ 'id' => revert[0], 'index' => revert[1] })
  #   tag_message = "reverted to #{info.inspect}"
  #   git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  # end

  # def checked_out2(id, index, files, stdout, stderr, status, summary)
  #   info = json_plain(summary['checkout'])
  #   tag_message = "checked out #{info.inspect}"
  #   git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  # end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    tag_message = "ran tests, no prediction, got #{summary['colour']}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  def predicted_right(id, index, files, stdout, stderr, status, summary)
    tag_message = "ran tests, predicted #{summary['predicted']}, got #{summary['colour']}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  def predicted_wrong(id, index, files, stdout, stderr, status, summary)
    tag_message = "ran tests, predicted #{summary['predicted']}, got #{summary['colour']}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  def reverted(id, index, files, stdout, stderr, status, summary)
    revert = summary['revert']
    info = json_plain({ 'id' => revert[0], 'index' => revert[1] })
    tag_message = "reverted to #{info.inspect}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  def checked_out(id, index, files, stdout, stderr, status, summary)
    info = json_plain(summary['checkout'])
    tag_message = "checked out #{info.inspect}"
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def option_get(id, name)
    fail_unless_known_option(name)
    read_options(disk, id)[name]
  end

  def option_set(id, name, value)
    fail_unless_known_option(name)
    possibles = (name === 'theme') ? ['dark','light'] : ['on', 'off']
    unless possibles.include?(value)
      fail "Cannot set theme to #{value}, only to one of #{possibles}"
    end
    if option_get(id, name) === value
      return
    end
    git_ff_merge_worktree(repo_dir(id)) do |worktree|
      options = read_options(worktree)
      options[name] = value
      write_files(worktree, '', { options_filename => json_pretty(options) })
      shell.assert_cd_exec(worktree.root_dir, [
        'git add .',
        "git commit --allow-empty --all --message 'set option #{name} to #{value}' --quiet",
      ])
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def download(id)
    # If id == 'vqzjS7' then repo_dir(id) is '/cyber-dojo/katas/vq/zj/S7/'
    # and the root-dir of the tar command is 'S7'.
    # So using --transform to create root-dir with a name
    # matching the tzg filename itself.
    year, month, day = *time.now
    user_name = "cyber-dojo-#{year}-#{month}-#{day}-#{id}"
    Dir.mktmpdir do |tmp_dir|
      tgz_command = "tar -czf #{tmp_dir}/#{user_name}.tgz --transform s/^./#{user_name}/ ."
      shell.assert_cd_exec(repo_dir(id), tgz_command)
      tgz_file_path = "#{tmp_dir}/#{user_name}.tgz"
      [ "#{user_name}.tgz", Base64.encode64(File.read(tgz_file_path)) ]
    end
  end

  include Fork
  include Options

  private

  include IdPather
  include JsonAdapter
  include PolyFiller

  def readme_filename(id)
    kata_id_path(id, 'README.md')
  end

  def readme(manifest)
    id = manifest['id']
    exercise = manifest['exercise']
    display_name = manifest['display_name']

    if exercise.nil?
      info = "- Custom exercise: `#{display_name}`\n"
    else
      info = [
        "- Exercise: `#{exercise}`",
        "- Language & test-framework: `#{display_name}`",
      ].join("\n")
    end
    [
      "# This a copy of [your cyber-dojo exercise](https://cyber-dojo.org/kata/edit/#{id}):",
      info,
      "",
      "## How to upload your cyber-dojo exercise to GitHub:",
      "- Go to your github on browser.",
      "- Create a new repo for your cyber-dojo practice. For example `cyber-dojo-2021-7-11-bR2hnf`",
      "- Execute the instructions shown in GitHub to 'push an existing repository from the command line'",
      "The instructions will look like this:",
      "```",
      "git remote add origin https://github.com/diegopego/cyber-dojo-2021-7-11-bR2hnf.git",
      "git branch -M main",
      "git push -u origin main",
      "```",
    ].join("\n")
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def git_commit_tag(id, index, files, summary, tag_message)
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    status = 0
    git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
  end
  
  def git_commit_tag_sss(id, index, files, stdout, stderr, status, summary, tag_message)
    all_events = nil
    git_ff_merge_worktree(repo_dir(id)) do |worktree|
      # Update events in worktree
      all_events = read_events(worktree)
      last_index = all_events.last['index']

      unless index == last_index+1
        raise 'Out of order event'
      end

      # Remove files/
      # Assumes there is always at least one file, and cyber-dojo.sh cannot be deleted.
      shell.assert_cd_exec(worktree.root_dir, 'git rm -r files/')

      # Write new files/
      write_files(worktree, 'files', content_of(files))

      # Add all files/
      shell.assert_cd_exec(worktree.root_dir, 'git add .')

      # Calculate number of added/deleted lines
      info = shell.assert_cd_exec(worktree.root_dir, "git diff #{index-1} --staged --shortstat --ignore-cr-at-eol")
      # Eg ' 1 file changed, 2 insertions(+), 1 deletion(-)'
      # Eg ' 1 file changed, 1 insertion(+)'
      # Eg ' 1 file changed, 172 deletions(-)'
      regex1 = /\d+ files? changed, (\d+) insertions?\(\+\), (\d+) deletion/
      regex2 = /\d+ files? changed, (\d+) insertions?\(\+\)/
      regex3 = /\d+ files? changed, (\d+) deletions?\(\-\)/
      if m = info.match(regex1) 
        added_count, deleted_count = *m.captures
      elsif m = info.match(regex2)
        added_count, deleted_count = *m.captures, 0
      elsif m = info.match(regex3)
        added_count, deleted_count = 0, *m.captures
      else 
        added_count, deleted_count = 0, 0
      end

      # Write the new event
      all_events << summary.merge!({ 
        'index' => index, 
        'time' => time.now,
        'diff_added_count' => added_count.to_i,
        'diff_deleted_count' => deleted_count.to_i
      })
      write_files(worktree, '', { events_filename => json_pretty(all_events) })

      # Update metadata
      write_files(worktree, '', {
        'stdout' => stdout['content'],
        'stderr' => stderr['content'],
        'status' => status.to_s,
        'truncations.json' => json_pretty({
          'stdout' => stdout['truncated'],
          'stderr' => stderr['truncated']
        })
      })

      # Add new event and metadata
      shell.assert_cd_exec(worktree.root_dir, 'git add .')

      # Commit
      shell.assert_cd_exec(worktree.root_dir, "git commit --message '#{index} #{tag_message}' --quiet")
    end

    # git_ff_merge_worktree succeeded, so tag
    shell.assert_cd_exec(repo_dir(id), ["git tag #{index} HEAD"])

    { 
      'next_index' => index + 1, 
      'major_index' => major_index(all_events, index),
      'minor_index' => 0
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def git_ff_merge_worktree(repo_dir)
    branch = random.alphanumeric(8)
    worktree_dir = "/tmp/#{branch}"
    shell.assert_cd_exec(repo_dir, "git worktree add #{worktree_dir}")
    worktree = External::Disk.new(worktree_dir)
    yield worktree
    shell.assert_cd_exec(repo_dir, "git merge --ff-only #{branch}")
  ensure
    shell.assert_cd_exec(repo_dir,
      "git worktree remove --force #{branch}",
      "git branch --delete --force #{branch}",
      "rm -rf #{worktree_dir}"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def read_events(disk, id=nil)
    # eg
    # [
    #  { "index": 0, ..., "event": "created" },
    #  { "index": 1, ..., "colour": "red"    },
    #  { "index": 2, ..., "colour": "amber"  }
    # ]
    read_json(disk, events_filename(id))
  end

  def read_options(disk, id=nil)
    read_json(disk, options_filename(id))
  end

  def read_manifest(id)
    # eg { "display_name": "Ruby, MiniTest",...}
    read_json(disk, manifest_filename(id))
  end

  def read_json(disk, filename)
    json_parse(read(disk, filename))
  end

  def read(disk, filename)
    command = disk.file_read_command(filename)
    content = disk.assert(command)
    Utf8.clean(content)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_filename(id)
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/manifest.json'
    kata_id_path(id, 'manifest.json')
  end

  def options_filename(id=nil)
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/options.json'
    if id.nil?
      'options.json'
    else
      kata_id_path(id, options_filename)
    end
  end

  def events_filename(id=nil)
    # eg id == 'SyG9sT' ==> '/katas/Sy/G9/sT/events.json'
    if id.nil?
      'events.json'
    else
      kata_id_path(id, events_filename)
    end
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
    commands = files.each.with_object([]) do |(filename,content),array|
      path = "#{base_dir}/#{filename}"
      array << disk.file_write_command(path, content)
    end
    disk.assert_all(commands)
  end

  def make_dirs(disk, base_dir, files)
    dirs = files.keys.each.with_object([]) do |filename, array|
      path = "#{base_dir}/#{filename}"
      array << File.dirname(path)
    end
    commands = (dirs.uniq.sort - ['/']).map{|dir| disk.dir_make_command(dir)}
    # Eg [ 'a/b', 'a/b/c' ] which must be created in that order
    # because the make_dir command is not idempotent.
    disk.assert_all(commands)
  end

  def repo_dir(id)
    # eg /cyber-dojo/katas/R2/mR/cV
    '/' + disk.root_dir + '/' + kata_dir(id)
  end

  def kata_dir(id)
    kata_id_path(id) # relative to /cyber-dojo/ eg '/katas/R2/mR/cV
  end

  def content_of(files)
    files.map{|filename,file| [filename,file['content']]}.to_h
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

# - - - - - - - - - - - - - - - - - - - -

def edited_filename(previous_files, current_files)
  previous_files.each do |filename, values|
    previous_content = previous_files[filename]['content']
    current_content = current_files[filename]['content']
    if previous_content != current_content
      return filename
    end
  end
  return nil
end

def major_index(events, index)
  # assert index > 0
  count = 0
  events[1..].each do |event|
    if is_light?(event)
      count += 1
    end
  end
  count
end
