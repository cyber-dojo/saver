require_relative 'fork'
require_relative 'git_diff'
require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'options'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'
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
# Because of this, ran_tests() et-all now returns three indexes:
#   index       - events[i].index == i
#   major_index - the previous red/amber/green index
#   minor_index - the non red/amber/green index between major_indexes
# For example, the events.json above
#   0=create, 1=rename, 2=edit, 3=ran-tests, 4=edit, 5=edit, 6=ran-tests
# correspond to major_index.minor_index values of
#   0->0.0    1->0.1    2->0.2  3->1.0       4->1.1  5->1.2  6->2.0

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

    # Compute each file's bytes once, so the working-tree write and the initial
    # commit use identical bytes and the committed tree matches the working tree
    # (as the old `git add .` made it).
    manifest_json = json_pretty(manifest)
    options_json  = json_pretty(default_options)
    events_json   = json_pretty(events)
    readme_md     = readme(manifest)
    files_content = content_of(files)

    disk.assert_all([
      disk.file_create_command(manifest_filename(id), manifest_json),
      disk.file_create_command(options_filename(id), options_json),
      disk.file_create_command(events_filename(id), events_json),
      disk.file_create_command(readme_filename(id), readme_md)
    ])
    write_files(disk, "#{kata_dir(id)}/files", files_content)

    initial_files = {
      'manifest.json' => manifest_json,
      'options.json'  => options_json,
      'events.json'   => events_json,
      'README.md'     => readme_md
    }
    files_content.each { |name, content| initial_files["files/#{name}"] = content }
    git.create(repo_dir(id), id, "#{id}@cyber-dojo.org", '0 kata creation', initial_files)

    id
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    result = read_manifest(id)
    polyfill_manifest_defaults(result)
    default_options.each_key do |name|
      result[name] = option_get(id, name)
    end
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = read_events_via_git(id)
    event = result[0]
    event['colour'] = 'create'
    event['diff_added_count'] = 0
    event['diff_deleted_count'] = 0
    polyfill_major_minor_events(result)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    event_from(id, index, events(id))
  end

  # Like event(id, index) but reuses an already-read events list, so callers
  # that already have it (e.g. file_edit) don't trigger a second git show of
  # events.json. See docs/reads-via-git.md.
  def event_from(id, index, all_events)
    index = index.to_i

    if index < 0
      pos_index = all_events.size + index
    else
      pos_index = index
    end

    unless pos_index >= 0
      message = "Invalid -ve index #{index} (=> #{pos_index}) [#{plural(all_events.size, :event)}]"
      raise message
    end

    unless pos_index < all_events.size
      message = "Invalid +ve index #{index} [#{plural(all_events.size, :event)}]"
      raise message
    end

    result = { 'files' => {} }
    truncations = nil

    git_archive(id, pos_index).each do |filename, content|
      # tag_tree_blobs yields blobs only (no directory markers), so every
      # filename is a real path.
      if filename.start_with?('files/')
        result['files'][filename['files/'.size..-1]] = { 'content' => content }
      elsif ['stdout', 'stderr'].include?(filename)
        result[filename] = { 'content' => content }
      elsif filename == 'status'
        result['status'] = content
      elsif filename == 'events.json'
        event = json_parse(content)[pos_index]
        result.merge!(event)
      elsif filename == 'truncations.json'
        truncations = json_parse(content)
      end
    end

    if result.has_key?('stdout')
      result['stdout']['truncated'] = truncations['stdout']
      result['stderr']['truncated'] = truncations['stderr']
    end

    if pos_index == 0
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

  def file_create(id, files, filename, laptop_id)
    # Called just BEFORE filename is created in the browser.
    # So it is NOT yet present in files.keys

    file_edit(id, files, laptop_id)
    files[filename] = { 'content' => '' }
    summary = { 'colour' => 'file_create', 'filename' => filename }
    # No quotes around the filename: the old save committed via a shell command
    # whose quoting stripped them, so historically the stored message had none.
    # The commit is now in-process (rugged), which uses the message literally.
    tag_message = "created file #{filename}"
    result = git_commit_tag(id, files, summary, tag_message, laptop_id)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_delete(id, files, filename, laptop_id)
    # Called just BEFORE filename is deleted in the browser.
    # So it IS present in files.

    file_edit(id, files, laptop_id)
    files.delete(filename)
    summary = { 'colour' => 'file_delete', 'filename' => filename }
    # No quotes: see the note in file_create.
    tag_message = "deleted file #{filename}"
    result = git_commit_tag(id, files, summary, tag_message, laptop_id)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_rename(id, files, old_filename, new_filename, laptop_id)
    # Called just BEFORE the rename in the browser.
    # So old_filename IS present in files.
    # And new_filename is NOT present in files.

    file_edit(id, files, laptop_id)
    files[new_filename] = files.delete(old_filename)
    summary = {
      'colour' => 'file_rename',
      'old_filename' => old_filename,
      'new_filename' => new_filename
    }
    tag_message = "renamed file #{old_filename} to #{new_filename}"
    result = git_commit_tag(id, files, summary, tag_message, laptop_id)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_edit(id, files, laptop_id)
    # Called in many places in the browser to indicate
    # that a file MAY have been edited (since the last save).
    # Creates a saver event if any file has been edited.
    # NOTE WELL: Called at the start of ALL other functions to
    # catch newly created/edited files.

    all_events = events(id)
    last_index = all_events[-1]['index'] # all_events.size - 1
    current_files = event_from(id, last_index, all_events)['files']
    edited_filename = edited_filename(current_files, files)
    if !edited_filename
      # nothing edited, so nothing is committed and the head does not move; the
      # next position stays head + 1.
      return last_index + 1
    end

    summary = { 'colour' => 'file_edit', 'filename' => edited_filename }
    # No quotes: see the note in file_create.
    tag_message = "edited file #{edited_filename}"
    result = git_commit_tag(id, files, summary, tag_message, laptop_id)
    result['next_index']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # Runs the internal file_edit that captures any pending edit before a test-family
  # event (ran_tests/predicted_right/predicted_wrong all call it first). A
  # concurrent same-laptop write can win the slot first, so this file_edit loses
  # the update-ref compare-and-swap and, being a file-event, is dropped as "Out of
  # order" (a file-event CAS-loss is not retried). That is benign for a solo user:
  # the pending edit is still carried by the following test event's own files, so
  # swallow that specific drop and let the caller commit the test anyway (placed at
  # head + 1 like any write). Any other error propagates.
  def file_edit_before_test_event(id, files, laptop_id)
    file_edit(id, files, laptop_id)
  rescue => error
    raise unless error.message.include?('Out of order event')
  end

  def ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    file_edit_before_test_event(id, files, laptop_id)
    tag_message = "ran tests, no prediction, got #{summary['colour']}"
    git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)
  end

  def predicted_right(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    file_edit_before_test_event(id, files, laptop_id)
    tag_message = "ran tests, predicted #{summary['predicted']}, got #{summary['colour']}"
    git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)
  end

  def predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    file_edit_before_test_event(id, files, laptop_id)
    tag_message = "ran tests, predicted #{summary['predicted']}, got #{summary['colour']}"
    git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)
  end

  def reverted(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    revert = summary['revert']
    info = json_plain({ 'id' => revert[0], 'index' => revert[1] })
    # info.inspect added escaping that the old shell-quoting path stripped back
    # out, so the historical message was the plain JSON. The in-process (rugged)
    # commit uses the message literally, so embed the plain JSON directly.
    tag_message = "reverted to #{info}"
    git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)
  end

  def checked_out(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    info = json_plain(summary['checkout'])
    # Plain JSON, not info.inspect: see the note in reverted.
    tag_message = "checked out #{info}"
    git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def option_get(id, name)
    fail_unless_known_option(name)
    read_options_via_git(id)[name]
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
    # Build the options.json change as an in-process commit on a single base,
    # then advance main onto it with an update-ref compare-and-swap on that same
    # base. No worktree, no checkout (the working tree stays stale; option_get
    # reads via git). The CAS gives loser detection: a concurrent winner makes it
    # fail. See docs/in-process-git.md.
    result = git.commit_options(repo_dir(id), "set option #{name} to #{value}") do |options|
      options[name] = value
      { options_filename => json_pretty(options) }
    end
    # Stays a git shell call (not rugged): rugged's high-level API does not expose
    # update-ref's old-value precondition (libgit2's git_reference_create_matching),
    # and that precondition is the concurrency mechanism, so it cannot be dropped.
    # See the fuller note in commit_event and docs/in-process-git.md.
    shell.assert_cd_exec(repo_dir(id), "git update-ref refs/heads/main #{result[:new_oid]} #{result[:base_oid]}")
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def download(id)
    # Build the download from committed git state, not the working tree, so it
    # is correct even when the working tree is stale (see docs/reads-via-git.md).
    # git clone gives a fresh repo with the full history and tags and a checkout
    # of HEAD; remove the local-path origin it adds so the result is a plain repo
    # the user can push to GitHub. The clone dir is named after the tgz, so the
    # tarball's root dir matches the filename.
    year, month, day = *time.now
    user_name = "cyber-dojo-#{year}-#{month}-#{day}-#{id}"
    Dir.mktmpdir do |tmp_dir|
      clone_dir = "#{tmp_dir}/#{user_name}"
      shell.assert_cd_exec(repo_dir(id), "git clone --quiet . #{clone_dir}")
      shell.assert_cd_exec(clone_dir, "git remote remove origin")
      shell.assert_cd_exec(tmp_dir, "tar -czf #{user_name}.tgz #{user_name}")
      tgz_file_path = "#{tmp_dir}/#{user_name}.tgz"
      [ "#{user_name}.tgz", Base64.encode64(File.read(tgz_file_path)) ]
    end
  end

  include Fork
  include GitDiff
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

  def git_commit_tag(id, files, summary, tag_message, laptop_id)
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    status = 0
    # File events carry no tab_seq yet, so no dedup key: pass nil explicitly.
    git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, nil)
  end

  def git_commit_tag_sss(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)
    all_events = commit_event(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq)

    {
      'next_index' => all_events.last['index'] + 1,
      'major_index' => major_index(all_events),
      'minor_index' => 0
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # A same-laptop test-family write that loses the update-ref compare-and-swap is
  # re-appended on the new head (self-lag), retrying up to this many times. The
  # bound is generous: concurrent same-laptop writes for one kata are few (a
  # browser fires only a couple at once) and each retry drains one winner, so this
  # only caps pathological contention.
  COMMIT_EVENT_MAX_RETRIES = 10

  def commit_event(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq, attempts = 0)
    # Builds the event commit in-process (libgit2/rugged) on a single base,
    # advances main onto it with an update-ref compare-and-swap, then tags it.
    # No worktree, no working-tree checkout (the working tree stays stale; reads
    # go via git). See docs/in-process-git.md.
    #
    # Placement is saver-authoritative: commit_on_main assigns the position at
    # head + 1 and yields it as place_at; the caller sends no index. The saver
    # never rejects a write for a stale or wrong client index - mobbing detection
    # lives in the browser's read-side poll, not here.
    #
    # The remaining out-of-sync handling is the concurrent-write race (the rescue
    # below): two saves for the same kata build on the same base_oid; whichever
    # reaches the update-ref compare-and-swap second fails (main has moved off
    # base_oid). The rescue resolves that loser: a file-event loser is dropped as
    # "Out of order" (superseded - its files are already in the winner); a
    # test-family loser rebuilds on the new head and re-appends so it lands after
    # the winner in order. Bounded by COMMIT_EVENT_MAX_RETRIES.
    #
    # Idempotency (A8): a write whose (laptop_id, tab_seq) is already committed is
    # a redelivery, so it is a no-op. Return the committed events unchanged, so the
    # caller reports the same position the original commit produced.
    if tab_seq
      committed = read_events_via_git(id)
      if committed.any? { |event| event['laptop_id'] == laptop_id && event['tab_seq'] == tab_seq }
        return committed
      end
    end

    all_events = nil
    result = git.commit_on_main(repo_dir(id), tag_message, content_of(files)) do |base_events, place_at, added, deleted|
      new_event = summary.merge!({
        'index' => place_at,
        'time' => time.now,
        'diff_added_count' => added,
        'diff_deleted_count' => deleted
      })
      # Only stamp the writing laptop when a well-formed id was supplied. A nil,
      # absent, or malformed laptop_id stores no laptop_id key at all, so such an
      # event is indistinguishable from a pre-laptop_id event and its writer is
      # treated as unknown. Only the genuine minted format is trusted.
      new_event['laptop_id'] = laptop_id if valid_laptop_id?(laptop_id)
      # Store the tab_seq so a later redelivery of this write can be recognised
      # as an already-committed (laptop_id, tab_seq) and deduplicated above.
      new_event['tab_seq'] = tab_seq unless tab_seq.nil?
      all_events = base_events + [new_event]
      {
        events_filename => json_pretty(all_events),
        'stdout' => stdout['content'],
        'stderr' => stderr['content'],
        'status' => status.to_s,
        'truncations.json' => json_pretty({
          'stdout' => stdout['truncated'],
          'stderr' => stderr['truncated']
        })
      }
    end

    # Advance main with a compare-and-swap on the base the commit was built on:
    # a concurrent winner makes the CAS fail (main no longer at base_oid). Then
    # tag the new commit with its numeric index.
    #
    # This stays a git shell call (not rugged): the CAS is the only step here
    # that cannot be done in-process via libgit2/rugged. update-ref's old-value
    # precondition (set main to <new> only if it is still <base>) maps to
    # libgit2's git_reference_create_matching, but rugged's high-level API does
    # not surface it -- references offers create (force-overwrite, not a CAS) and
    # update, neither with an expected-old-value check. That precondition IS the
    # concurrency mechanism (loser detection), so it cannot be dropped. See
    # docs/in-process-git.md.
    shell.assert_cd_exec(repo_dir(id), "git update-ref refs/heads/main #{result[:new_oid]} #{result[:base_oid]}")
    git.create_tag(repo_dir(id), result[:place_at], result[:new_oid])

    all_events
  rescue
    # A raised error here is normally the update-ref compare-and-swap losing: a
    # concurrent write for this kata advanced main off the base this commit was
    # built on. Read the tip via git (the working tree is stale; HEAD advances
    # atomically via update-ref, so this sees the latest committed events - see
    # read_events_via_git and docs/reads-via-git.md). The saver does not reject a
    # write for its index, so the only in-flight failure to sort out here is a
    # lost compare-and-swap; any other error left the tip where it was.
    current_events = read_events_via_git(id)
    if result.nil? || current_events.last['index'] < result[:place_at]
      # commit_on_main failed to build the commit (result nil), or the tip did not
      # pass our place_at - either way this was not a lost CAS, so re-raise as-is.
      raise
    end

    # A concurrent same-kata write won the compare-and-swap.
    # - file-event loser: superseded (the winner's files already include this
    #   event's file changes), so drop it as "Out of order" (the caller's
    #   inter-test handler discards a superseded file event silently). No retry.
    # - test-family loser: rebuild on the new head and re-append so it lands after
    #   the winner in order (append-only). On retry commit_on_main accepts the
    #   behind write and places it at the new head + 1 - self-lag (this laptop's
    #   own lost-response write) or a concurrent write from another laptop alike;
    #   the read-side poll flags any staleness. Bounded against pathological
    #   contention.
    if summary['colour'].to_s.start_with?('file_') || attempts >= COMMIT_EVENT_MAX_RETRIES
      raise "Out of order event for #{id}"
    end
    commit_event(id, files, stdout, stderr, status, summary, tag_message, laptop_id, tab_seq, attempts + 1)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # A laptop_id is the 64-char lowercase-hex cookie minted by web
  # (SecureRandom.hex(32)). Anything else (nil, wrong length, non-hex,
  # uppercase) is not trusted and is not stored, so the event reads as having
  # an unknown writer.
  def valid_laptop_id?(laptop_id)
    laptop_id.is_a?(String) && laptop_id.match?(/\A[0-9a-f]{64}\z/)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # Reads the kata git tree at the commit tagged pos_index, in-process via
  # libgit2 (rugged), as { path => content }. Equivalent to
  # "git archive --format=tar <index>" (hence the method name). See
  # docs/in-process-git.md.
  #
  # A save commits its event (advancing main via git update-ref) and then, as a
  # separate step, writes that index's numeric tag (via rugged). A concurrent
  # reader can observe the new index in events.json before its tag exists, so the
  # tag lookup raises External::Git::TagNotFound. The caller has already validated
  # pos_index against events.json, so this is the transient tag-write window:
  # retry briefly until the writer finishes; if the retries are exhausted (a
  # genuine missing tag) the exception is re-raised.
  GIT_ARCHIVE_MAX_RETRIES   = 100
  GIT_ARCHIVE_RETRY_SECONDS = 0.01

  def git_archive(id, pos_index)
    attempts = 0
    blobs =
      begin
        git.tag_tree_blobs(repo_dir(id), pos_index)
      rescue External::Git::TagNotFound
        attempts += 1
        raise if attempts > GIT_ARCHIVE_MAX_RETRIES
        sleep(GIT_ARCHIVE_RETRY_SECONDS)
        retry
      end
    # tag_tree_blobs returns blob bytes tagged ASCII-8BIT. The kata's stored
    # files, stdout/stderr, events.json and truncations.json are all UTF-8 text,
    # so retag them as UTF-8 (scrubbing any invalid bytes), exactly as the old
    # shell path did (git archive's stdout went through External::Shell, which
    # Utf8.cleans), matching read_events_via_git. Without this, content with
    # non-ASCII bytes compares unequal to the same text after it has round-tripped
    # through JSON (file_edit would log a phantom edit), and JSON-serialising the
    # event response warns (and raises under json 3.0).
    blobs.transform_values { |content| Utf8.clean(content) }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # Reads the kata's committed events.json through git rather than off the
  # working tree. The working tree is stale (saves no longer refresh it; they
  # advance main with git update-ref, no checkout), so its events.json is not
  # the latest. HEAD (the kata's main branch) advances atomically and the
  # committed blob exists before the ref moves, so this always returns the
  # whole, consistent, latest events.json. See docs/reads-via-git.md.
  def read_events_via_git(id)
    json_parse(Utf8.clean(git_show(id, 'events.json')))
  end

  # Reads the kata's committed options.json through git rather than off the
  # working tree. option_set advances main with git update-ref without a
  # checkout, so the working-tree options.json is stale; reading at HEAD (which
  # advances atomically) gives the latest. See git_show and docs/reads-via-git.md.
  def read_options_via_git(id)
    json_parse(Utf8.clean(git_show(id, 'options.json')))
  end

  # Reads filename from the kata's git tree at HEAD as a string, in-process via
  # libgit2 (rugged). Equivalent to "git show HEAD:<filename>". See
  # docs/in-process-git.md.
  def git_show(id, filename)
    git.head_blob(repo_dir(id), filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def read_manifest(id)
    # eg { "display_name": "Ruby, MiniTest",...}
    # Read from the working tree, not via git. manifest.json is written once at
    # create() and never rewritten (saves change events.json and metadata;
    # option_set changes options.json; nothing changes the manifest), so it is
    # immutable. Its create-time working-tree copy therefore always equals the
    # committed content, even now that saves no longer refresh the working tree,
    # so reading it from the working tree is correct and needs no git. See
    # docs/reads-via-git.md.
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

  def git
    @externals.git
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
  current_filenames = current_files.keys
  previous_files.each do |filename, values|
    unless current_filenames.include?(filename)
      # Can occur for v2 katas created before file-events became live.
      # Can also occur if there is a saver outage that misses a file-delete event.
      # See test/server/kata_ran_tests_with_outage.rb
      next
    end
    previous_content = values['content']
    current_content = current_files[filename]['content']
    if previous_content != current_content
      return filename
    end
  end
  return nil
end

def major_index(events)
  count = 0
  events[1..].each do |event|
    if is_light?(event)
      count += 1
    end
  end
  count
end

def plural(n, word)
  if n == 1
    "#{n} #{word}"
  else
    "#{n} #{word}s"
  end
end
