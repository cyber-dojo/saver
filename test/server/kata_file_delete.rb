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

      files = kata_event(id, -1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert_v2_last_commit_message(id, '1 deleted file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # TODO: add test for kata_file_delete when one other file has been edited

end
