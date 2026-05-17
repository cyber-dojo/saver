require_relative 'test_base'

class KataRevertedTest < TestBase

  version_test 2, '67DDk6', %w(
  | kata_reverted stores a reverted event with correct commit message
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      kata_ran_tests(id, index=2, files, stdout, stderr, status, red_summary)
      reverted_summary = { 
        'colour' => 'red', 
        'revert' => [id, index=1] 
      }
      kata_reverted(id, index=3, files, stdout, stderr, status, reverted_summary)
      expected = JSON.generate({'id': id, 'index': 1})
      assert_tag_commit_message(id, 3, "3 reverted to #{expected}")
      [index, reverted_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, '67DDk7', %w(
  | kata_reverted event has revert field
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      kata_ran_tests(id, index=2, files, stdout, stderr, status, red_summary)
      reverted_summary = { 
        'colour' => 'red', 
        'revert' => [id, index=1] 
      }

      result = kata_reverted(id, index=3, files, stdout, stderr, status, reverted_summary)
      next_index = result['next_index']

      actual = kata_event(id, next_index - 1)
      assert actual.keys.include?('revert'), :no_revert_key
      expected = [id, 1]
      assert_equal expected, actual['revert']

      actual = kata_events(id)[next_index - 1]
      assert actual.keys.include?('revert'), :no_revert_key
      assert_equal expected, actual['revert']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test '67DDk8', %w(
  | kata_reverted raises NoLongerImplementedError
  | when legacy writes are disabled
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      data = bats
      reverted_summary = { 'colour' => 'red', 'revert' => [id, 0] }
      externals.allow_legacy_writes = false
      assert_raises(NoLongerImplementedError) do
        kata_reverted(id, 1, files, data['stdout'], data['stderr'], data['status'], reverted_summary)
      end
    end
  end

end
