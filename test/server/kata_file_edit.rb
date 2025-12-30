require_relative 'test_base'

class KataFileEditTest < TestBase

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
  |a kata_file_edit event 
  |does NOT create any new events
  ) do
    in_tennis_kata do |id, files|
      new_index = kata_file_edit(id, index=1, files)

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
  |a kata_file_edit event 
  |results in a single edit-file event 
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content

      new_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename']
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 1, '1 edited file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'E03', %w(
  |in versions 0 and 1, kata_file_edit
  |returns unchanged index argument and does nothing
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']

      expected = kata_events(id)
      new_index = kata_file_edit(id, index=1, files)
      actual = kata_events(id)

      assert_equal index, new_index
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E04', %w(
  |when one file has been edited
  |a kata_ran_test2 event 
  |results in two events
  ) do
    in_kata do |id|

      files = kata_event(id, 0)['files']
      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content

      data = bats
      stdout = data['stdout']
      stderr = data['stderr']
      status = data['status']

      new_index = kata_ran_tests2(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 3, new_index
      assert_equal 3, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'file_edit', events[1]['colour']
      assert_equal 'readme.txt', events[1]['filename'] # cyber-dojo.sh
      files = kata_event(id, 1)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 1, '1 edited file readme.txt')

      assert_equal 2, events[2]['index']
      assert_equal 'red', events[2]['colour']
    end
  end
end
