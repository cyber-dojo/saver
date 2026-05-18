require_relative 'test_base'

class KataPredictedWrongTest < TestBase

  version_test 2, 'B1DE03', %w(
  | kata_predicted_wrong stores a predicted-wrong event with correct commit message
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
  | kata_predicted_wrong raises NoLongerImplementedError
  | on v0/v1 katas
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    id = kids[version]
    files = kata_event(id, 0)['files']
    data = bats
    summary = red_summary.merge({ 'predicted' => 'green' })
    assert_raises(NoLongerImplementedError) do
      kata_predicted_wrong(id, 1, files, data['stdout'], data['stderr'], data['status'], summary)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B1DE05', %w(
  | when one file has been edited
  | a kata_predicted_wrong2 event 
  | results in two events
  | and returns a dict containing 
  | next_index, and major_index which is an index of
  | traffic-lights
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']

      next_index = 1
      next_index = kata_file_create(id, next_index, files, 'wibble1.txt')
      assert_equal 2, next_index
      next_index = kata_file_create(id, next_index, files, 'wibble2.txt')
      assert_equal 3, next_index
      next_index = kata_file_rename(id, next_index, files, 'wibble2.txt', 'wibble3.txt')
      assert_equal 4, next_index

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']

      actual = kata_predicted_wrong(id, next_index, files, stdout, stderr, status, red_summary)
      expected = { 'next_index' => 6, 'major_index' => 1, 'minor_index' => 0 }
      assert_equal expected, actual

      next_index = expected['next_index']
      next_index = kata_file_create(id, next_index, files, 'wibble3.txt')
      assert_equal 7, next_index
      next_index = kata_file_create(id, next_index, files, 'wibble4.txt')
      assert_equal 8, next_index
      next_index = kata_file_rename(id, next_index, files, 'wibble4.txt', 'wibble5.txt')
      assert_equal 9, next_index

      actual = kata_predicted_wrong(id, next_index, files, stdout, stderr, status, red_summary)
      expected = { 'next_index' => 10, 'major_index' => 2, 'minor_index' => 0 }
      assert_equal expected, actual
    end
  end
end
