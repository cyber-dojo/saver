require_relative 'test_base'

class KataPredictedRightTest < TestBase

  version_test 2, '535E03', %w(
  | kata_predicted_right stores a predicted-right event with correct commit message
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']
      summary = red_summary.merge({ 'predicted' => 'red' })
      kata_predicted_right(id, files, stdout, stderr, status, summary)
      assert_tag_commit_message(id, 1, '1 ran tests, predicted red, got red')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test '535E04', %w(
  | kata_predicted_right raises NoLongerImplementedError
  | on v0/v1 katas
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    id = kids[version]
    files = kata_event(id, 0)['files']
    data = bats
    summary = red_summary.merge({ 'predicted' => 'red' })
    assert_raises(NoLongerImplementedError) do
      kata_predicted_right(id, files, data['stdout'], data['stderr'], data['status'], summary)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '535E05', %w(
  | when one file has been edited
  | a kata_predicted_right event results in two committed events - the pending
  | file_edit, then the light - and the committed light carries a major_index
  | that counts the traffic-lights (minor_index 0).
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

      kata_predicted_right(id, files, stdout, stderr, status, red_summary)
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

      kata_predicted_right(id, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 10, events.size
      light = events[9]
      assert_equal 'red', light['colour']
      assert_equal 2, light['major_index']
      assert_equal 0, light['minor_index']
    end
  end
end
