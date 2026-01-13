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

  versions_01_test 'Dk8', %w(
  | in v0 and v1
  | kata_checked_out event is poly-filled with major_index and minor_index
  | and these do NOT see inter-test file-events.
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

      next_index = kata_file_create(id1, index=1, files, 'wibble1.txt')
      assert_equal 1, next_index

      result = kata_ran_tests(id1, next_index, files, stdout, stderr, status, red_summary)
      assert_equal 2, result['next_index']

      id2 = group_join(gid)
      checkout = { # This does NOT have major_index/minor_index
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
        'major_index' => 1,
        'minor_index' => 0,
        'avatarIndex' => group_index
      }
      assert_equal expected, actual['checkout']

      actual = kata_events(id2)[result['next_index'] - 1]
      assert actual.keys.include?('checkout'), :no_checkout_key
      assert_equal expected, actual['checkout']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Before I switch on file-events, major/minor indexes on
  # a checkout will always mirror plain index. Even for different avatars.
  # After file-events are enabled, they won't.
  # Is there a quick way to determine if a v2 kata has file-events?
  # I think there is: 
  #    event = events[-1]
  #    no_file_events = (event['index'] == event['major_index'])

=begin
  version_test 2, 'Dk9', %w(
  | in v2 checkout event is polyfilled with major_index and minor_index 
  | which works same as v0,v1 when there are NO inter-test file-events.
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
        'major_index' => 1,
        'minor_index' => 0,
        'avatarIndex' => group_index
      }
      assert_equal expected, actual['checkout']

      # TODO: This needs to check the event from kata_events() plural, too. See above.
    end
  end
=end

end
