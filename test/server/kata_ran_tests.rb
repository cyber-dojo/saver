require_relative 'test_base'

class KataRanTestsTest < TestBase

  versions_test 'Sp4Dk1', %w(
  | kata_ran_tests gives same results in all versions
  ) do
    in_kata do |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      assert_tag_commit_message(id, 1, '1 ran tests, no prediction, got red')
      [index, red_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Sp4Dk8', %w(
  | kata_ran_tests returns the next index in all versions
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
      assert_equal 'Out of order event', error.message
      [index=1, red_summary]
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
