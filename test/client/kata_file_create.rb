require_relative 'test_base'

class KataFileCreateTest < TestBase

  def self.id58_prefix
    'Dcc'
  end

  version_test 2, 'B01', %w(
  |when no files have been edited
  |a kata_file_create event 
  |results in a single create-file event
  |with the created file having empty content
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      filenames = files.keys
      refute filenames.include?('wibble.txt') 

      new_index = kata_file_create(id, index=1, files, 'wibble.txt')

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['index']
      assert_equal 'create-file', events[1]['event']
      assert_equal 'wibble.txt', events[1]['filename']

      files = kata_event(id, 1)['files']
      filenames = files.keys
      assert filenames.include?('wibble.txt')
      assert_equal '', files['wibble.txt']['content']
    end
  end
end
