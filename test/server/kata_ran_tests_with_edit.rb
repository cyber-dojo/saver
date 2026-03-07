require_relative 'test_base'

class KataRanTestsWithEditTest < TestBase

  versions_01_test 'Sp5E04', %w(
  | when one file has been edited
  | a kata_ran_test event 
  | results in ONE event
  | and returns a dict containing 
  | next_index, and major_index which is an index of
  | traffic-lights
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      next_index = 1

      actual = kata_ran_tests(id, next_index, files, stdout, stderr, status, red_summary)

      expected = { 'next_index' => 2, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual
      events = kata_events(id)
      assert_equal 'red', events[1]['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Sp5E05', %w(
  | when one file has been edited
  | a kata_ran_test event 
  | results in TWO events
  | and returns a dict containing 
  | next_index, and major_index which is an index of
  | traffic-lights
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      next_index = 1

      actual = kata_ran_tests(id, next_index, files, stdout, stderr, status, red_summary)

      expected = { 'next_index' => 3, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual
      events = kata_events(id)
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'red', events[2]['colour']
    end
  end
end
