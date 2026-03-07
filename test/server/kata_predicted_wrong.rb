require_relative 'test_base'

class KataPredictedWrongTest < TestBase

  versions_test 'B1DE03', %w(
  | kata_predicted_wrong gives same git-commit-message in all versions
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      summary = red_summary.merge({ 'predicted' => 'green' })
      kata_predicted_wrong(id, index=1, files, stdout, stderr, status, summary)
      assert_tag_commit_message(id, 1, '1 ran tests, predicted green, got red')
      [index, summary]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'B1DE04', %w(
  | when one file has been edited
  | a kata_predicted_wrong2 event 
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

      actual = kata_predicted_wrong(id, next_index, files, stdout, stderr, status, red_summary)

      expected = { 'next_index' => 2, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual
      events = kata_events(id)
      assert_equal 'red', events[1]['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'B1DE05', %w(
  | when one file has been edited
  | a kata_predicted_wrong2 event 
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

      actual = kata_predicted_wrong(id, next_index, files, stdout, stderr, status, red_summary)

      expected = { 'next_index' => 3, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual
      events = kata_events(id)
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'red', events[2]['colour']
    end
  end
end
