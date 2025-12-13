require_relative 'test_base'

class KataFileSwitchTest < TestBase

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'E01', %w(
  |when no files have been edited
  |a kata_file_switch event 
  |does NOT create any new events
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      new_index = kata_file_switch(id, index=1, files)

      events = kata_events(id)
      assert_equal 1, new_index
      assert_equal 1, events.size

      assert_equal 0, events[0]['index']      
      assert_equal 'create', events[0]['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'E02', %w(
  |when one file has been edited
  |a kata_file_switch event 
  |results in a single edit-file event 
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      files['readme.txt']['content'] += 'Hello world'

      new_index = kata_file_switch(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'edit-file', events[1]['event']
      assert_equal 'readme.txt', events[1]['filename']
    end
  end
end
