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
  |when no files have been edited
  |a kata_file_switch event 
  |does NOT create any new events
  ) do
    in_tennis_kata do |id, files|
      new_index = kata_file_switch(id, index=1, files)

      events = kata_events(id)
      assert_equal 1, new_index
      assert_equal 1, events.size

      assert_equal 0, events[0]['index']      
      assert_equal 'created', events[0]['event']
      assert_tag_commit_message(id, 0, '0 kata creation')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E02', %w(
  |when one file has been edited
  |a kata_file_switch event 
  |results in a single edit-file event 
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content

      new_index = kata_file_switch(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file-edit', events[1]['event']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 1, '1 edited file readme.txt')
    end
  end
end
