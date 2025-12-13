require_relative 'test_base'

class KataFileRenameTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D01', %w(
  |when no other file has been edited
  |a kata_file_rename event
  |results in a rename-file event 
  ) do
    in_tennis_kata do |id, files|
      content = files['readme.txt']['content']
      kata_file_rename(id, index=1, files, 'readme.txt', 'readme.md')

      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'rename-file', event1['colour']
      assert_equal 'readme.txt', event1['old_filename']
      assert_equal 'readme.md', event1['new_filename']

      files = kata_event(id, -1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert filenames.include?('readme.md')
      assert_equal content, files['readme.md']['content']
      assert_tag_commit_message(id, 1, '1 renamed file readme.txt to readme.md')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D02', %w(
  |when one other file has been edited
  |a kata_file_rename event 
  |results in two events
  |the first for the edit
  |the second for the renamed file
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['tennis.py']['content'] + '# some comment'
      renamed_content = files['readme.txt']['content']
      files['tennis.py']['content'] = edited_content
      kata_file_rename(id, index=1, files, 'readme.txt', 'readme.md')

      events = kata_events(id)
      assert_equal 3, events.size

      event1 = events[1]
      assert_equal 1, event1['index']
      assert_equal 'edit-file', event1['colour']
      assert_equal 'tennis.py', event1['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['tennis.py']['content']
      assert_tag_commit_message(id, 1, '1 edited file tennis.py')

      event2 = events[2]
      assert_equal 2, event2['index']
      assert_equal 'rename-file', event2['colour']
      assert_equal 'readme.txt', event2['old_filename']
      assert_equal 'readme.md', event2['new_filename']
      files = kata_event(id, 2)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert filenames.include?('readme.md')
      assert_equal renamed_content, files['readme.md']['content']
      assert_tag_commit_message(id, 2, '2 renamed file readme.txt to readme.md')
    end
  end
end
