require_relative 'test_base'

class KataFileDeleteTest < TestBase

  version_test 2, 'DccC01', %w(
  | when no files have been edited
  | a kata_file_delete event
  | results in a single delete-file event 
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      assert files.keys.include?('readme.txt') 

      next_index = kata_file_delete(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_delete', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      refute files.keys.include?('readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'DccC02', %w(
  | when one file has been edited
  | and a different file has been deleted
  | a kata_file_delete event 
  | results in two events
  | the first for the edit
  | the second for the delete
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      assert files.keys.include?('readme.txt') 

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      
      next_index = kata_file_delete(id, index=1, files, 'tennis.py')

      events = kata_events(id)
      assert_equal 3, next_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']

      assert_equal 2, events[2]['index']
      assert_equal 'file_delete', events[2]['colour']
      assert_equal 'tennis.py', events[2]['filename']
      files = kata_event(id, 2)['files']
      refute files.keys.include?('tennis.py')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'DccC03', %w(
  | when one file has been edited
  | and the same file has been deleted
  | a kata_file_delete event 
  | results in two events
  | the first for the edit
  | the second for the delete
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      assert files.keys.include?('readme.txt') 

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      
      next_index = kata_file_delete(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 3, next_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']

      assert_equal 2, events[2]['index']
      assert_equal 'file_delete', events[2]['colour']
      assert_equal 'readme.txt', events[2]['filename']
      files = kata_event(id, 2)['files']
      refute files.keys.include?('readme.txt')
    end
  end  
end
