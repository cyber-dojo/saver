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
  | There is a window between the git merge --ff-only (which updates
  | events.json to include the new index) and the separate git tag
  | <index> HEAD that records the numeric tag for that index. A concurrent
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
    window_shell = Class.new do
      def initialize(real)
        @real = real
        @opened = false
      end
      def assert_cd_exec(path, *commands)
        if !@opened && commands.flatten.any? { |c| c.to_s.start_with?('git archive') }
          @opened = true
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

    externals.instance_variable_set('@shell', window_shell)

    # The losing concurrent save (same index 1) must report out-of-order,
    # not the raw "not a valid object name" git diagnostic.
    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, 1, files, stdout, stderr, status, red_summary)
    }
    assert_equal "Out of order event for #{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkE', %w(
  | event()'s git-archive retry only swallows the transient "not a valid
  | object name" tag-write window. A git archive failure for any other
  | reason is re-raised immediately, with no retry.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)

    fail_shell = Class.new do
      def assert_cd_exec(*)
        raise 'simulated git archive failure'
      end
    end.new

    externals.instance_variable_set('@shell', fail_shell)

    error = assert_raises(RuntimeError) { kata_event(id, 0) }
    assert_equal 'simulated git archive failure', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp4DkF', %w(
  | When the "not a valid object name" window never closes (the numeric
  | tag is never written), event()'s git-archive retry is bounded: it
  | gives up and re-raises rather than looping forever.
  ) do
    gid = group_create(custom_manifest)
    id  = group_join(gid)

    always_missing_shell = Class.new do
      def assert_cd_exec(*)
        raise 'fatal: not a valid object name: 0'
      end
    end.new

    externals.instance_variable_set('@shell', always_missing_shell)

    error = assert_raises(RuntimeError) { kata_event(id, 0) }
    assert_equal 'fatal: not a valid object name: 0', error.message
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
