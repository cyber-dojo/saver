require_relative 'test_base'

class KataRanTestsTest < TestBase

  version_test 2, 'Sp4Dk1', %w(
  | kata_ran_tests stores a ran-tests event with correct commit message
  ) do
    in_kata do |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      assert_tag_commit_message(id, 1, '1 ran tests, no prediction, got red')
      [index, red_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4Dk8', %w(
  | kata_ran_tests returns next_index incremented by 1
  ) do
    in_kata do |id, files, stdout, stderr, status|
      result = kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      next_index = result['next_index']
      assert_equal 2, next_index
      [index=1, red_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4Dk9', %w(
  | kata_ran_tests with an already used index
  | raises "Out of order event" exception
  ) do
    in_kata do |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      error = assert_raises(RuntimeError) {
        kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      }
      assert_equal "Out of order event for #{id}", error.message
      [index=1, red_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkC', %w(
  | a non-out-of-sync failure inside the worktree block
  | (e.g. git commit failing) is re-raised as-is,
  | not converted to "Out of order event"
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)
    files  = kata_event(id, 0)['files']
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    status = 0

    error_shell = Class.new do
      def initialize(real)
        @real = real
      end
      def assert_cd_exec(path, *commands)
        if commands.flatten.any? { |c| c.to_s.start_with?('git commit') }
          raise RuntimeError, 'simulated git commit failure'
        end
        @real.assert_cd_exec(path, *commands)
      end
      def cd_exec(path, command)
        @real.cd_exec(path, command)
      end
    end.new(shell)

    externals.instance_variable_set('@shell', error_shell)

    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, 1, files, stdout, stderr, status, red_summary)
    }
    assert_equal 'simulated git commit failure', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkD', %w(
  | There is a window between the ref advance (git update-ref, which moves
  | main to the commit that adds the new index to events.json) and the separate
  | git tag <index> HEAD that records the numeric tag for that index. A concurrent
  | save that loses the race reads the new last_index from events.json,
  | then calls event() -> git archive --format=tar <index>, which fails
  | with "not a valid object name" because the numeric tag is not written
  | yet. This transient read failure must not surface as a raw git
  | diagnostic; it must resolve to the normal "Out of order event".
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)
    files  = kata_event(id, 0)['files']
    stdout = { 'content' => '', 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    status = 0

    # First save succeeds: events.json gains index 1 and tag 1 is written.
    kata_ran_tests(id, 1, files, stdout, stderr, status, red_summary)

    # Wrap the shell so the next "git archive --format=tar 1" reproduces the
    # window: tag 1 is momentarily absent (a genuine git failure) and then
    # restored, exactly as a concurrent winner's "git tag 1 HEAD" closes it.
    tag_race_shell = Class.new do
      attr_reader :reproduced
      def initialize(real)
        @real = real
        @reproduced = false
      end
      def assert_cd_exec(path, *commands)
        if !@reproduced && commands.flatten.any? { |c| c.to_s.start_with?('git archive') }
          @reproduced = true
          @real.assert_cd_exec(path, 'git tag --delete 1')
          begin
            @real.assert_cd_exec(path, *commands)
          ensure
            @real.assert_cd_exec(path, 'git tag 1 HEAD')
          end
        else
          @real.assert_cd_exec(path, *commands)
        end
      end
      def cd_exec(path, command)
        @real.cd_exec(path, command)
      end
    end.new(shell)

    externals.instance_variable_set('@shell', tag_race_shell)

    # The losing concurrent save (same index 1) must report out-of-order,
    # not the raw "not a valid object name" git diagnostic.
    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, 1, files, stdout, stderr, status, red_summary)
    }
    assert_equal "Out of order event for #{id}", error.message
    # Confirm the race was actually reproduced: a stale save reports
    # "Out of order event" anyway, so without this the test could pass without
    # exercising the git archive recovery at all.
    assert tag_race_shell.reproduced, 'tag-write race was never reproduced'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkE', %w(
  | event()'s git-archive retry only swallows the transient "not a valid
  | object name" tag-write window. A git archive failure for any other
  | reason is re-raised immediately, with no retry.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)

    archive_shell = shell_failing_git_archive_with('simulated git archive failure')
    externals.instance_variable_set('@shell', archive_shell)

    error = assert_raises(RuntimeError) { kata_event(id, 0) }
    assert_equal 'simulated git archive failure', error.message
    # git archive was reached and re-raised immediately, with no retry.
    assert_equal 1, archive_shell.git_archive_calls
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkF', %w(
  | When the "not a valid object name" window never closes (the numeric
  | tag is never written), event()'s git-archive retry is bounded: it
  | gives up and re-raises rather than looping forever.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)

    archive_shell = shell_failing_git_archive_with('fatal: not a valid object name: 0')
    externals.instance_variable_set('@shell', archive_shell)

    error = assert_raises(RuntimeError) { kata_event(id, 0) }
    assert_equal 'fatal: not a valid object name: 0', error.message
    # git archive was retried to exhaustion before re-raising.
    assert_equal Kata_v2::GIT_ARCHIVE_MAX_RETRIES + 1, archive_shell.git_archive_calls
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # A shell that passes every command through to the real shell except
  # "git archive", which it fails with the given message. Lets event()'s
  # events read (git show) succeed so the failure isolates to git_archive.
  def shell_failing_git_archive_with(message)
    Class.new do
      attr_reader :git_archive_calls
      def initialize(real, message)
        @real = real
        @message = message
        @git_archive_calls = 0
      end
      def assert_cd_exec(path, *commands)
        if commands.flatten.any? { |c| c.to_s.start_with?('git archive') }
          @git_archive_calls += 1
          raise @message
        end
        @real.assert_cd_exec(path, *commands)
      end
    end.new(shell, message)
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
      kata_ran_tests(id, 1, files, data['stdout'], data['stderr'], data['status'], red_summary)
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
      kata_ran_tests(id, 1, files, data['stdout'], data['stderr'], data['status'], red_summary)
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

    kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

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
