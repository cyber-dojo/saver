require_relative 'test_base'

class KataFileDeleteTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C01', %w(
  |when no files have been edited
  |a kata_file_delete event
  |results in a single delete-file event 
  ) do
    in_tennis_kata do |id, files|
      new_index = kata_file_delete(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'delete-file', events[1]['event']
      assert_equal 'readme.txt', events[1]['filename']

      files = kata_event(id, 1)['files']
      refute files.keys.include?('readme.txt')
      assert_tag_commit_message(id, 1, '1 deleted file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C02', %w(
  |when one file has been edited
  |and a different file has been deleted
  |a kata_file_delete event 
  |results in two events
  |the first for the edit
  |the second for the delete
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      
      new_index = kata_file_delete(id, index=1, files, 'tennis.py')

      events = kata_events(id)
      assert_equal 3, new_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'edit-file', events[1]['event']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 1, '1 edited file readme.txt')

      assert_equal 2, events[2]['index']
      assert_equal 'delete-file', events[2]['event']
      assert_equal 'tennis.py', events[2]['filename']
      files = kata_event(id, 2)['files']
      refute files.keys.include?('tennis.py')
      assert_tag_commit_message(id, 2, '2 deleted file tennis.py')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C03', %w(
  |when one file has been edited
  |and the same file has been deleted
  |a kata_file_delete event 
  |results in two events
  |the first for the edit
  |the second for the delete
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      
      new_index = kata_file_delete(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 3, new_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'edit-file', events[1]['event']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 1, '1 edited file readme.txt')

      assert_equal 2, events[2]['index']
      assert_equal 'delete-file', events[2]['event']
      assert_equal 'readme.txt', events[2]['filename']
      files = kata_event(id, 2)['files']
      refute files.keys.include?('readme.txt')
      assert_tag_commit_message(id, 2, '2 deleted file readme.txt')
    end
  end  
end
