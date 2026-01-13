require_relative 'test_base'

class KataCheckedOutTest < TestBase
  def self.id58_prefix
    '77B'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk7', %w(
  | kata_checked_out gives same git-commit-message in all versions
  ) do
    in_group do |gid|
      id1 = group_join(gid)
      manifest = kata_manifest(id1)
      group_index = manifest["group_index"]
      files = kata_event(id1, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      kata_ran_tests(id1, index=1, files, stdout, stderr, status, red_summary)

      id2 = group_join(gid)
      checkout = { 
        'id' => id1, 
        'index' => 1, 
        'avatarIndex' => group_index 
      }
      checkout_out_summary = { 
        'colour' => 'red', 
        'checkout' => checkout 
      }
      kata_checked_out(id2, index=1, files, stdout, stderr, status, checkout_out_summary)

      expected = JSON.generate(checkout)
      assert_tag_commit_message(id2, 1, "1 checked out #{expected}")
      [index, checkout_out_summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk8', %w(
  | kata_checked_out event is poly-filled in all versions
  ) do
    in_group do |gid|
      id1 = group_join(gid)
      manifest = kata_manifest(id1)
      group_index = manifest["group_index"]
      files = kata_event(id1, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      kata_ran_tests(id1, index=1, files, stdout, stderr, status, red_summary)

      id2 = group_join(gid)
      checkout = { 
        'id' => id1, 
        'index' => 1, 
        'avatarIndex' => group_index 
      }
      checkout_out_summary = { 
        'colour' => 'red', 
        'checkout' => checkout 
      }

      result = kata_checked_out(id2, index=1, files, stdout, stderr, status, checkout_out_summary)

      actual = kata_event(id2, result['next_index'] - 1)
      assert actual.keys.include?('checkout'), :no_checkout_key
      expected = {
        'id' => id1,
        'index' => 1,
        'avatarIndex' => group_index
      }
      assert_equal expected, actual['checkout']
    end
  end

end
