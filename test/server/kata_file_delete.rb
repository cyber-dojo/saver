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
  |when no other file has been edited
  |a kata_file_delete event
  |results in a single delete-file event 
  ) do
    in_tennis_kata do |id, files|
      kata_file_delete(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'delete-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']

      files = kata_event(id, 1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert_v2_last_commit_message(id, '1 deleted file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C02', %w(
  |when one other file has been edited
  |a kata_file_delete event 
  |results in two events
  |the first for the edit
  |the second for the deleted file
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content
      kata_file_delete(id, index=1, files, 'tennis.py')

      events = kata_events(id)
      assert_equal 3, events.size

      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'edit-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      # TODO: assert_v2_commit_message(id, tag, expected)

      event2 = events[2]
      assert_equal 2, event2['index']
      assert_equal 'delete-file', event2['colour']
      assert_equal 'tennis.py', event2['filename']
      files = kata_event(id, 2)['files']
      filenames = files.keys
      refute filenames.include?('tennis.py')
      assert_v2_last_commit_message(id, '2 deleted file tennis.py')
      
    end
  end
end
