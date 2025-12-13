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
  |when no other file has been edited
  |a kata_file_create event 
  |results in a single create-file event
  |with the created file having empty content
  ) do
    in_tennis_kata do |id, files|
      kata_file_create(id, index=1, 'wibble.txt')

      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']
      assert_equal 'create-file', event1['colour']
      assert_equal 'wibble.txt', event1['filename']

      files = kata_event(id, -1)['files']
      filenames = files.keys
      assert filenames.include?('wibble.txt')
      assert_equal '', files['wibble.txt']['content']
      assert_v2_last_commit_message(id, '1 created file wibble.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # TODO: add test for kata_file_create when one other file has been edited

end
