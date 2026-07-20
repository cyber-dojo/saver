require_relative 'test_base'

class KataRanTestsWithEditTest < TestBase

  test 'Sp5E05', %w(
  | when one file has been edited
  | a kata_ran_tests event results in two committed events - the pending
  | file_edit, then the ran-tests light - and the committed light carries a
  | major_index that counts the traffic-lights (minor_index 0).
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']

      kata_file_create(id, files, 'wibble1.txt')
      assert_equal 2, kata_events(id).size
      kata_file_create(id, files, 'wibble2.txt')
      assert_equal 3, kata_events(id).size
      kata_file_rename(id, files, 'wibble2.txt', 'wibble3.txt')
      assert_equal 4, kata_events(id).size

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']

      kata_ran_tests(id, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 6, events.size
      assert_equal 'file_edit', events[4]['colour']
      light = events[5]
      assert_equal 'red', light['colour']
      assert_equal 1, light['major_index']
      assert_equal 0, light['minor_index']

      kata_file_create(id, files, 'wibble3.txt')
      assert_equal 7, kata_events(id).size
      kata_file_create(id, files, 'wibble4.txt')
      assert_equal 8, kata_events(id).size
      kata_file_rename(id, files, 'wibble4.txt', 'wibble5.txt')
      assert_equal 9, kata_events(id).size

      kata_ran_tests(id, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 10, events.size
      light = events[9]
      assert_equal 'red', light['colour']
      assert_equal 2, light['major_index']
      assert_equal 0, light['minor_index']
    end
  end
end
