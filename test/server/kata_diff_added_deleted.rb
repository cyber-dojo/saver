require_relative 'test_base'

class KataDiffAddedDeletedTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  def self.id58_prefix
    'A6A'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E01', %w(
  | when a file has been edited
  | a kata_file_edit event 
  | shows diff_added_lines, diff_deleted_lines
  ) do
    in_tennis_kata do |id, files|
      edited_content = files['readme.txt']['content'] + "Hello\nworld\n"
      files['readme.txt']['content'] = edited_content
      new_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, new_index
      assert_equal 2, events.size

      assert_equal 2, events[1]['diff_added_count']
      assert_equal 1, events[1]['diff_deleted_count']
    end
  end

end
