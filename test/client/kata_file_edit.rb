require_relative 'test_base'

class KataFileEditTest < TestBase

  version_test 2, 'DccE01', %w(
  | when no files have been edited
  | a kata_file_edit event 
  | does NOT create any new events
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      next_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 1, next_index
      assert_equal 1, events.size

      assert_equal 0, events[0]['index']      
      assert_equal 'create', events[0]['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'DccE02', %w(
  | when one file has been edited
  | a kata_file_edit event 
  | results in a single edit-file event 
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content

      next_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
    end
  end
end
