require_relative 'test_base'

class KataFileCreateTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B01', %w(
  |when no files have been edited
  |a kata_file_create event 
  |results in a single create-file event
  |with the created file having empty content
  ) do
    in_tennis_kata do |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)

      new_index = kata_file_create(id, index=2, files, 'wibble.txt')

      events = kata_events(id)
      assert_equal 3, new_index
      assert_equal 3, events.size
      
      assert_equal 2, events[2]['index']
      assert_equal 'file-create', events[2]['event']
      assert_equal 'wibble.txt', events[2]['filename']

      files = kata_event(id, 2)['files']
      assert files.keys.include?('wibble.txt')
      assert_equal '', files['wibble.txt']['content']
      assert_tag_commit_message(id, 2, '2 created file wibble.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B02', %w(
  |when one other file has been edited
  |a kata_file_create event 
  |results in two events
  |the first for the edit (and *NOT* the created file)
  |the second for the newly created file
  ) do
    in_tennis_kata do |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)

      edited_content = files['readme.txt']['content'] + 'Hello world'
      files['readme.txt']['content'] = edited_content

      # VIP: at this point 'wibble.txt', the new filename, is NOT in files
      new_index = kata_file_create(id, index=2, files, 'wibble.txt')

      events = kata_events(id)
      assert_equal 4, new_index
      assert_equal 4, events.size

      assert_equal 2, events[2]['index']
      assert_equal 'file-edit', events[2]['event']
      assert_equal 'readme.txt', events[2]['filename']
      files = kata_event(id, 2)['files']
      assert_equal edited_content, files['readme.txt']['content']
      assert_tag_commit_message(id, 2, '2 edited file readme.txt')
      refute files.keys.include?('wibble.txt')

      assert_equal 3, events[3]['index']
      assert_equal 'file-create', events[3]['event']
      assert_equal 'wibble.txt', events[3]['filename']
      files = kata_event(id, 3)['files']
      assert_equal '', files['wibble.txt']['content']
      assert_tag_commit_message(id, 3, '3 created file wibble.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'B03', %w(
  |in versions 0 and 1, kata_file_create
  |returns unchanged index argument and does nothing
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      refute files.keys.include?('wibble.txt') 

      expected = kata_events(id)
      new_index = kata_file_create(id, index=1, files, 'wibble.txt')
      actual = kata_events(id)

      assert_equal index, new_index
      assert_equal expected, actual
    end
  end

end
