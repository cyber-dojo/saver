require_relative 'test_base'

class KataRevertedTest < TestBase
  def self.id58_prefix
    '67D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk6', %w(
  | kata_reverted gives same git-commit-message in all versions
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

  versions_test 'Dk7', %w(
  | kata_reverted has revert field in all versions 
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

end
