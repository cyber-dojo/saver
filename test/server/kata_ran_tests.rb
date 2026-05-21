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
