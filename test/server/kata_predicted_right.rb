require_relative 'test_base'

class KataPredictedRightTest < TestBase

  versions_test '535E03', %w(
  | kata_predicted_right gives same tag-commit-message in all versions
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      summary = red_summary.merge({ 'predicted' => 'red' })
      kata_predicted_right(id, index=1, files, stdout, stderr, status, summary)
      assert_tag_commit_message(id, 1, '1 ran tests, predicted red, got red')
      [index, summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test '535E04', %w(
  | when one file has been edited
  | a kata_predicted_right2 event 
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

      actual = kata_predicted_right(id, next_index, files, stdout, stderr, status, red_summary)

      expected = { 'next_index' => 2, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual
      events = kata_events(id)
      assert_equal 'red', events[1]['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, '535E05', %w(
  | when one file has been edited
  | a kata_predicted_right2 event 
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

      actual = kata_predicted_right(id, next_index, files, stdout, stderr, status, red_summary)

      expected = { 'next_index' => 3, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual
      events = kata_events(id)
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'red', events[2]['colour']
    end
  end
end
