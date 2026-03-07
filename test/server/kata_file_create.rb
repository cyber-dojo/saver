require_relative 'test_base'

class KataFileCreateTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'DcAB04', %w(
  | returns unchanged index argument and does nothing.
  | In v2, the file-create-event comes in when the
  | is actually created, when it is always EMPTY.
  | That is NOT very interesting in a review.
  | So instead, all other events first check for a new file.
  | For example, if you create a new file, edit it, and then
  | switch to a different file, the switch will cause an
  | incoming file-edit event, which will see the new file
  | with its initial NON-EMPTY content.
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      refute files.keys.include?('wibble.txt') 

      before = kata_events(id)
      next_index = kata_file_create(id, index=1, files, 'wibble.txt')
      after = kata_events(id)

      assert_equal index, next_index
      assert_equal before, after
    end
  end

end
