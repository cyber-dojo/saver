require_relative 'test_base'

class KataCheckedOutTest < TestBase

  version_test 2, '77BDk7', %w(
  | kata_checked_out stores a checked-out event with correct commit message
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
      kata_ran_tests(id1, files, stdout, stderr, status, red_summary)

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
      kata_checked_out(id2, files, stdout, stderr, status, checkout_out_summary)

      expected = JSON.generate(checkout)
      assert_tag_commit_message(id2, 1, "1 checked out #{expected}")
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, '77BDk8', %w(
  | kata_checked_out event has checkout field
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

      result = kata_ran_tests(id1, files, stdout, stderr, status, red_summary)
      assert_equal 2, result['next_index']

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

      result = kata_checked_out(id2, files, stdout, stderr, status, checkout_out_summary)
      next_index = result['next_index']

      actual = kata_event(id2, next_index - 1)
      assert actual.keys.include?('checkout'), :no_checkout_key
      expected = {
        'id' => id1,
        'index' => 1,
        'avatarIndex' => group_index
      }
      assert_equal expected, actual['checkout']

      actual = kata_events(id2)[next_index - 1]
      assert actual.keys.include?('checkout'), :no_checkout_key
      assert_equal expected, actual['checkout']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test '77BDkA', %w(
  | kata_checked_out raises NoLongerImplementedError
  | on v0/v1 katas
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    id = kids[version]
    files = kata_event(id, 0)['files']
    data = bats
    checkout_summary = {
      'colour' => 'red',
      'checkout' => { 'id' => id, 'index' => 0, 'avatarIndex' => 0 }
    }
    assert_raises(NoLongerImplementedError) do
      kata_checked_out(id, files, data['stdout'], data['stderr'], data['status'], checkout_summary)
    end
  end

end
