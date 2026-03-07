require_relative 'test_base'

class KataFileCreateTest < TestBase

  versions_test 'DccB01', %w(
  | kata_file_create
  | returns unchanged index argument and does nothing
  | In v2, this is because the file-create-event comes in
  | when the file is actually created, when it is always empty.
  | That is not very interesting in a review.
  | So instead, all other events first check for a new file.
  | For example, if you create a new file, edit it, and then
  | switch to a new file, switching to a new file will cause
  | an incoming file-edit event, which will see the new file
  | with its initial non-empty content.
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      refute files.keys.include?('wibble.txt') 

      next_index = kata_file_create(id, index=1, files, 'wibble.txt')

      events = kata_events(id)
      assert_equal 1, next_index
      assert_equal 1, events.size
    end
  end

end
