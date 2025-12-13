require_relative 'test_base'

class KataFileDeleteTest < TestBase

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'C01', %w(
  |when no files have been edited
  |a kata_file_delete event
  |results in a single delete-file event 
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      filenames = files.keys
      assert filenames.include?('readme.txt') 

      new_index = kata_file_delete(id, index=1, files, 'readme.txt')

      assert_equal 2, new_index
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'delete-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']

      files = kata_event(id, 1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'C02', %w(
  |when one file has been edited
  |and a different file has been deleted
  |a kata_file_delete event 
  |results in two events
  |the first for the edit
  |the second for the delete
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      filenames = files.keys
      assert filenames.include?('readme.txt') 

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      
      new_index = kata_file_delete(id, index=1, files, 'tennis.py')

      assert_equal 3, new_index
      events = kata_events(id)
      assert_equal 3, events.size

      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'edit-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']

      event2 = events[2]
      assert_equal 2, event2['index']
      assert_equal 'delete-file', event2['colour']
      assert_equal 'tennis.py', event2['filename']
      files = kata_event(id, 2)['files']
      filenames = files.keys
      refute filenames.include?('tennis.py')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'C03', %w(
  |when one file has been edited
  |and the same file has been deleted
  |a kata_file_delete event 
  |results in two events
  |the first for the edit
  |the second for the delete
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      filenames = files.keys
      assert filenames.include?('readme.txt') 

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      
      new_index = kata_file_delete(id, index=1, files, 'readme.txt')

      assert_equal 3, new_index
      events = kata_events(id)
      assert_equal 3, events.size

      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'edit-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']

      event2 = events[2]
      assert_equal 2, event2['index']
      assert_equal 'delete-file', event2['colour']
      assert_equal 'readme.txt', event2['filename']
      files = kata_event(id, 2)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
    end
  end  
end
