require_relative 'test_base'

class KataRanTestsTest < TestBase

  version_test 2, 'Sp4Dk1', %w(
  | kata_ran_tests stores a ran-tests event with correct commit message
  ) do
    in_kata do |id, files, stdout, stderr, status|
      kata_ran_tests(id, files, stdout, stderr, status, red_summary, laptop_id)
      assert_tag_commit_message(id, 1, '1 ran tests, no prediction, got red')
      [1, red_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4Dk8', %w(
  | kata_ran_tests returns next_index incremented by 1
  ) do
    in_kata do |id, files, stdout, stderr, status|
      result = kata_ran_tests(id, files, stdout, stderr, status, red_summary, laptop_id)
      next_index = result['next_index']
      assert_equal 2, next_index
      [index=1, red_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkC', %w(
  | a non-out-of-sync failure during the commit (e.g. the git update-ref that
  | advances main failing for a reason other than losing a concurrent race)
  | is re-raised as-is, not converted to "Out of order event". The rescue tells
  | the two apart by re-reading events.json: here main never advanced (so
  | last_index is still index-1), which marks it a genuine error to re-raise.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)
    files  = kata_event(id, 0)['files']
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    status = 0

    error_shell = Class.new do
      # commit_event's only shell call is the update-ref CAS, so raising here
      # simulates that ref advance failing for a non-race reason.
      def assert_cd_exec(_path, *_commands)
        raise RuntimeError, 'simulated update-ref failure'
      end
    end.new

    externals.instance_variable_set('@shell', error_shell)

    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, files, stdout, stderr, status, red_summary, laptop_id)
    }
    assert_equal 'simulated update-ref failure', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkD', %w(
  | There is a window between the ref advance (git update-ref, which moves main to
  | the commit that adds the new index to events.json) and the separate git tag
  | <index> that records the numeric tag. A save whose internal read lands in that
  | window calls event() -> git_archive, whose tag lookup raises TagNotFound
  | because the tag is not written yet. git_archive retries over the window; once
  | the tag lands the read recovers, so nothing surfaces raw and the save is
  | accepted and appended at head+1.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)
    files  = kata_event(id, 0)['files']
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    status = 0

    # First save succeeds: events.json gains index 1 and tag 1 is written.
    kata_ran_tests(id, files, stdout, stderr, status, red_summary, laptop_id)

    # Wrap the in-process git to reproduce the window: it delegates every call to
    # the real git, except the first tag_tree_blobs raises TagNotFound (tag
    # momentarily absent); the retry then delegates to the real git (tag present),
    # as a concurrent winner's git tag closes it.
    tag_race_git = Class.new do
      attr_reader :reproduced
      def initialize(real)
        @real = real
        @reproduced = false
      end
      def tag_tree_blobs(repo_dir, index)
        unless @reproduced
          @reproduced = true
          raise External::Git::TagNotFound, "no tag #{index}"
        end
        @real.tag_tree_blobs(repo_dir, index)
      end
      def method_missing(name, *args, &block)
        @real.public_send(name, *args, &block)
      end
      def respond_to_missing?(name, include_private = false)
        # Never exercised: the model calls tag_tree_blobs and the delegated methods
        # on the double, never respond_to? - so this line is excluded from coverage.
        # :nocov:
        @real.respond_to?(name, include_private)
        # :nocov:
      end
    end.new(git)

    externals.instance_variable_set('@git', tag_race_git)

    # The save's internal read hits the window and recovers, so the save is
    # accepted and appended at head+1 (index 2).
    result = kata_ran_tests(id, files, stdout, stderr, status, red_summary, laptop_id)

    assert_equal 3, result['next_index']
    assert_equal [0, 1, 2], kata_events(id).map { |e| e['index'] }
    # Confirm the window was actually reproduced, so the test really exercised
    # git_archive's tag-read retry rather than passing trivially.
    assert tag_race_git.reproduced, 'tag-write window was never reproduced'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkE', %w(
  | git_archive's retry only swallows TagNotFound (the transient tag-write
  | window). A tag-read failure for any other reason is re-raised immediately,
  | with no retry.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)

    failing_git = git_failing_tag_read_with(RuntimeError, 'simulated tag read failure')
    externals.instance_variable_set('@git', failing_git)

    error = assert_raises(RuntimeError) { kata_event(id, 0) }
    assert_equal 'simulated tag read failure', error.message
    # the tag read was reached and re-raised immediately, with no retry.
    assert_equal 1, failing_git.tag_read_calls
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkF', %w(
  | When the tag-write window never closes (the numeric tag is never written),
  | git_archive's retry on TagNotFound is bounded: it gives up and re-raises
  | rather than looping forever.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)

    failing_git = git_failing_tag_read_with(External::Git::TagNotFound, 'no tag 0')
    externals.instance_variable_set('@git', failing_git)

    assert_raises(External::Git::TagNotFound) { kata_event(id, 0) }
    # the tag read was retried to exhaustion before re-raising.
    assert_equal Kata_v2::GIT_ARCHIVE_MAX_RETRIES + 1, failing_git.tag_read_calls
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # An External::Git that delegates head_blob (so the events read succeeds) but
  # fails the tag read (tag_tree_blobs) with the given exception, counting calls.
  # Isolates the failure to git_archive's tag read.
  def git_failing_tag_read_with(klass, message)
    Class.new do
      attr_reader :tag_read_calls
      def initialize(real, klass, message)
        @real = real
        @klass = klass
        @message = message
        @tag_read_calls = 0
      end
      def head_blob(repo_dir, path)
        @real.head_blob(repo_dir, path)
      end
      def tag_tree_blobs(_repo_dir, _index)
        @tag_read_calls += 1
        raise @klass, @message
      end
    end.new(git, klass, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkR', %w(
  | A solo user's [test] fired while its own inter-test file_edit is still in flight
  | (waitForITE's 2s bail, an unsaved edit in the form) is not mobbing and must
  | commit. ran_tests runs an internal file_edit first; a stubbed git makes a
  | competing SAME-laptop file_edit win the slot between that internal file_edit's
  | base-read and its update-ref, so the internal file_edit loses the CAS and, being
  | file-family, is dropped (not retried). ran_tests tolerates that drop and commits
  | the [test] on the new head via self-lag: events 0 (create), 1 (competing
  | file_edit), 2 (the test).
  ) do
    assert_test_survives_raced_internal_file_edit do |id, files, stdout, stderr, status|
      kata_ran_tests(id, files, stdout, stderr, status, red_summary, laptop_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkS', %w(
  | As Sp4DkR for kata_predicted_right (predicted red, got red). predicted_right also
  | runs the internal file_edit first, so it tolerates the same dropped-CAS and
  | commits the predict event on the new head.
  ) do
    assert_test_survives_raced_internal_file_edit do |id, files, stdout, stderr, status|
      kata_predicted_right(id, files, stdout, stderr, status, red_summary.merge('predicted' => 'red'), laptop_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkT', %w(
  | As Sp4DkR for kata_predicted_wrong (predicted green, got red). predicted_wrong
  | also runs the internal file_edit first, so it tolerates the same dropped-CAS and
  | commits the predict event on the new head.
  ) do
    assert_test_survives_raced_internal_file_edit do |id, files, stdout, stderr, status|
      kata_predicted_wrong(id, files, stdout, stderr, status, red_summary.merge('predicted' => 'green'), laptop_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Drives the "a solo user's [test] races its own in-flight inter-test file_edit"
  # scenario for a test-family write (yielded). Sets up a kata with a pending edit,
  # installs a git that makes a competing SAME-laptop file_edit win the slot during
  # the write's internal file_edit (so it loses the CAS and is dropped), runs the
  # write with stderr captured (the expected CAS-loss "update_ref failed" is a
  # handled signal, kept out of the test output), and asserts the write still
  # commits: the competing file_edit lands at index 1 and the test-family event at
  # index 2. The block gets (id, files, stdout, stderr, status).
  def assert_test_survives_raced_internal_file_edit
    manifest = manifest_Tennis_refactoring_Python_unitttest
    manifest['version'] = @version
    gid = group_create(manifest)
    id  = group_join(gid)

    base_files = kata_event(id, 0)['files']
    filename   = base_files.keys.first
    stdout = bats['stdout']; stderr = bats['stderr']; status = bats['status']

    test_files      = base_files.merge(filename => { 'content' => base_files[filename]['content'] + "\ntest edit\n" })
    competing_files = base_files.merge(filename => { 'content' => base_files[filename]['content'] + "\ncompeting edit\n" })

    # The competing in-flight inter-test file_edit, same laptop, committed via a
    # real-git model on the same repo the instant before our update-ref CAS.
    competing_model = Externals.new.model
    inject = -> { competing_model.kata_file_edit(id: id, files: competing_files, laptop_id: laptop_id) }
    externals.instance_variable_set('@git', racing_git(git, inject))

    _stdout_captured, stderr_captured = capture_stdout_stderr do
      yield(id, test_files, stdout, stderr, status)
    end
    assert_includes stderr_captured, 'update_ref failed', stderr_captured

    events = kata_events(id)
    assert_equal [0, 1, 2], events.map { |e| e['index'] }, events.to_s
    assert_equal 1, events.count { |e| e['colour'] == 'red' }, events.to_s
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # A git wrapper that delegates to the real one, but the FIRST time commit_on_main
  # is called (the [test]'s internal file_edit) it fires on_first_commit AFTER the
  # real commit is built - i.e. after base_oid (the current head) is captured but
  # before the model's update-ref CAS. on_first_commit commits a competing same-
  # laptop file_edit that advances main to head+1, so the model's CAS (old = the
  # now-stale head) loses - exactly as a concurrent in-flight inter-test file_edit
  # would, but deterministic and single-threaded.
  def racing_git(real, on_first_commit)
    Class.new do
      def initialize(real, on_first_commit)
        @real = real
        @on_first_commit = on_first_commit
        @fired = false
      end
      def commit_on_main(repo_dir, message, files, &block)
        result = @real.commit_on_main(repo_dir, message, files, &block)
        unless @fired
          @fired = true
          @on_first_commit.call
        end
        result
      end
      def method_missing(name, *args, &block)
        @real.public_send(name, *args, &block)
      end
      def respond_to_missing?(name, include_private = false)
        # Never exercised: the model calls commit_on_main and the delegated methods
        # on the double, never respond_to? - so this line is excluded from coverage.
        # :nocov:
        @real.respond_to?(name, include_private)
        # :nocov:
      end
    end.new(real, on_first_commit)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'Sp4DkA', %w(
  | kata_ran_tests raises NoLongerImplementedError
  | on v0 katas
  ) do
    id = V0_KATA_ID
    files = kata_event(id, 0)['files']
    data = bats
    assert_raises(NoLongerImplementedError) do
      kata_ran_tests(id, files, data['stdout'], data['stderr'], data['status'], red_summary, laptop_id)
    end
  end

  version_test 1, 'Sp4DkB', %w(
  | kata_ran_tests raises NoLongerImplementedError
  | on v1 katas
  ) do
    id = V1_KATA_ID
    files = kata_event(id, 0)['files']
    data = bats
    assert_raises(NoLongerImplementedError) do
      kata_ran_tests(id, files, data['stdout'], data['stderr'], data['status'], red_summary, laptop_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkG', %w(
  | A save advances HEAD with git update-ref, not git merge --ff-only, so it
  | does NOT refresh the main working tree (the write speedup). Reads via git
  | still see the new committed state, but the save leaves the working-tree
  | events.json untouched.
  ) do
    id     = kata_create(custom_manifest)
    files  = kata_event(id, 0)['files']
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }

    path   = working_tree_path(id, 'events.json')
    before = File.read(path)

    kata_ran_tests(id, files, stdout, stderr, 0, red_summary, laptop_id)

    # correctness: the committed state advanced (read via git)
    assert_equal 2, kata_events(id).size
    # the speedup: the save did not refresh the working tree
    assert_equal before, File.read(path)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def in_kata
    manifest = manifest_Tennis_refactoring_Python_unitttest
    manifest['version'] = @version
    gid = group_create(manifest)
    id = group_join(gid)
    index = 1
    files = kata_event(id, 0)['files']
    stdout = bats['stdout']
    stderr = bats['stderr']
    status = bats['status']

    index, summary = *yield(id, files, stdout, stderr, status)

    actual = kata_event(id, index)
    assert_equal files, actual['files'], :files
    assert_equal stdout, actual['stdout'], :stdout
    assert_equal stderr, actual['stderr'], :stderr
    assert_equal status, actual['status'], :status
    assert_equal index, actual['index'], :index
    summary.keys.each do |key|
      expected = summary[key]
      assert_equal expected, actual[key], key
    end
  end
end
