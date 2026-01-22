require_relative 'test_base'

class KataFileCreateTest < TestBase

  version_test 2, 'DccB01', %w(
  | when no files have been edited
  | a kata_file_create event 
  | results in a single create-file event
  | with the created file having empty content
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      refute files.keys.include?('wibble.txt') 

      next_index = kata_file_create(id, index=1, files, 'wibble.txt')

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_create', events[1]['colour']
      assert_equal 'wibble.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert files.keys.include?('wibble.txt')
      assert_equal '', files['wibble.txt']['content']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'DccB02', %w(
  | when one other file has been edited
  | a kata_file_create event 
  | results in two events
  | the first for the edit
  | the second for the newly created file
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content

      next_index = kata_file_create(id, index=1, files, 'wibble.txt')

      events = kata_events(id)
      assert_equal 3, next_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']

      assert_equal 2, events[2]['index']
      assert_equal 'file_create', events[2]['colour']
      assert_equal 'wibble.txt', events[2]['filename']
      files = kata_event(id, 2)['files']
      assert_equal '', files['wibble.txt']['content']
    end
  end

end
