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
      kata_file_rename(id, index=1, 'readme.txt', 'readme.md')

      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']
      assert_equal 'rename-file', event1['colour']
      assert_equal 'readme.txt', event1['old_filename']
      assert_equal 'readme.md', event1['new_filename']

      files = kata_event(id, -1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert filenames.include?('readme.md')
      assert_equal content, files['readme.md']['content']
      assert_v2_last_commit_message(id, '1 renamed file readme.txt to readme.md')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # TODO: add test for kata_file_rename when one other file has been edited

end
