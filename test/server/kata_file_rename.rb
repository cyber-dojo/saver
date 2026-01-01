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
  | when no other file has been edited
  | a kata_file_rename event
  | results in a single rename-file event 
  ) do
    in_tennis_kata do |id, files|
      content = files['readme.txt']['content']
      
      new_index = kata_file_rename(id, index=1, files, 'readme.txt', 'readme.md')

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_rename', events[1]['colour']
      assert_equal 'readme.txt', events[1]['old_filename']
      assert_equal 'readme.md', events[1]['new_filename']

      files = kata_event(id, -1)['files']
      refute files.keys.include?('readme.txt')
      assert files.keys.include?('readme.md')
      assert_equal content, files['readme.md']['content']
      assert_tag_commit_message(id, 1, '1 renamed file readme.txt to readme.md')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D02', %w(
  | when one file has been edited
  | and a different file has been renamed
  | a kata_file_rename event 
  | results in two events
  | the first for the edit
  | the second for the rename
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['tennis.py']['content'] + '# some comment'
      renamed_content = files['readme.txt']['content']
      files['tennis.py']['content'] = edited_content
      
      new_index = kata_file_rename(id, index=1, files, 'readme.txt', 'readme.md')

      assert_equal 3, new_index
      events = kata_events(id)
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'tennis.py', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['tennis.py']['content']
      assert_tag_commit_message(id, 1, '1 edited file tennis.py')

      assert_equal 2, events[2]['index']
      assert_equal 'file_rename', events[2]['colour']
      assert_equal 'readme.txt', events[2]['old_filename']
      assert_equal 'readme.md', events[2]['new_filename']
      files = kata_event(id, 2)['files']
      refute files.keys.include?('readme.txt')
      assert files.keys.include?('readme.md')
      assert_equal renamed_content, files['readme.md']['content']
      assert_tag_commit_message(id, 2, '2 renamed file readme.txt to readme.md')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D03', %w(
  | when one file has been edited
  | and the same file has been renamed
  | a kata_file_rename event 
  | results in two events
  | the first for the edit
  | the second for the rename
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + '# some comment'
      files['readme.txt']['content'] = edited_content
      
      new_index = kata_file_rename(id, index=1, files, 'readme.txt', 'readme.md')

      events = kata_events(id)
      assert_equal 3, new_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 1, '1 edited file readme.txt')

      assert_equal 2, events[2]['index']
      assert_equal 'file_rename', events[2]['colour']
      assert_equal 'readme.txt', events[2]['old_filename']
      assert_equal 'readme.md', events[2]['new_filename']
      files = kata_event(id, 2)['files']
      refute files.keys.include?('readme.txt')
      assert files.keys.include?('readme.md')
      assert_equal edited_content, files['readme.md']['content']
      assert_tag_commit_message(id, 2, '2 renamed file readme.txt to readme.md')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'D04', %w(
  | in versions 0 and 1, kata_file_rename
  | returns unchanged index argument and does nothing
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      assert files.keys.include?('readme.txt') 

      expected = kata_events(id)
      new_index = kata_file_rename(id, index=1, files, 'readme.txt', 'readme2.txt')
      actual = kata_events(id)

      assert_equal index, new_index
      assert_equal expected, actual
    end
  end

end
