require_relative 'test_base'

class KataFileSwitchTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E01', %w(
  |kata_file_switch results in a switch-file event 
  |when the incoming files are identical to the existing most-recent files
  |and filename is the name of the (unedited) switched-to file
  ) do
    in_tennis_kata do |id, files|
      kata_file_switch(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']      
      assert_equal 'switch-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']
      assert_v2_last_commit_message(id, '1 switched to file readme.txt')

      # TODO: should this result in NO new events?      

    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E02', %w(
  |kata_file_switch results in an edit-file event 
  |when one file in the incoming files has been edited
  |and filename is the name of the edited file we just switched from
  ) do
    in_tennis_kata do |id, files|
      files['readme.txt']['content'] += 'Hello world'

      kata_file_switch(id, index=1, files, 'test_hiker.sh')
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']
      assert_equal 'edit-file', event1['colour']
      assert_equal 'readme.txt', event1['filename']
      assert_v2_last_commit_message(id, '1 edited file readme.txt')
    end
  end
end
