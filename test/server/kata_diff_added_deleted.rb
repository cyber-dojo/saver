require_relative 'test_base'

class KataDiffAddedDeletedTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A6AE01', %w(
  | when a file has lines added
  | a kata_file_edit event 
  | shows diff_added_lines=N, diff_deleted_lines=0
  ) do
    in_tennis_kata do |id, files|
      added_lines = ['Hello', 'world']
      edited_content = files['readme.txt']['content'] + "\n" + added_lines.join("\n")

      files['readme.txt']['content'] = edited_content
      next_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal added_lines.size, events[1]['diff_added_count']
      assert_equal 0, events[1]['diff_deleted_count']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A6AE02', %w(
  | when file has lines deleted
  | a kata_file_edit event 
  | shows diff_added_lines=0, diff_deleted_lines=N
  ) do
    in_tennis_kata do |id, files|
      deleted_content = files['readme.txt']['content']
      deleted_lines = deleted_content.split("\n")
      assert deleted_lines.size > 0

      files['readme.txt']['content'] = ''
      next_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 0, events[1]['diff_added_count']
      assert_equal deleted_lines.size, events[1]['diff_deleted_count']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A6AE03', %w(
  | when file is renamed
  | a kata_file_edit event 
  | shows diff_added_lines=0, diff_deleted_lines=0
  ) do
    in_tennis_kata do |id, files|
      next_index = kata_file_rename(id, index=1, files, 'readme.txt', 'readme2.txt')

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 0, events[1]['diff_added_count']
      assert_equal 0, events[1]['diff_deleted_count']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A6AE04', %w(
  | when a file is created
  | a kata_file_edit event 
  | shows diff_added_lines=0, diff_deleted_lines=0
  ) do
    in_tennis_kata do |id, files|
      next_index = kata_file_create(id, index=1, files, 'newfile.txt')

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 0, events[1]['diff_added_count']
      assert_equal 0, events[1]['diff_deleted_count']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A6AE05', %w(
  | when a file is deleted
  | a kata_file_edit event 
  | shows diff_added_lines=N, diff_deleted_lines=0
  ) do
    in_tennis_kata do |id, files|
      deleted_content = files['readme.txt']['content']
      deleted_lines = deleted_content.split("\n")
      assert deleted_lines.size > 0

      next_index = kata_file_delete(id, index=1, files, 'readme.txt')

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 0, events[1]['diff_added_count']
      assert_equal deleted_lines.size, events[1]['diff_deleted_count']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A6AE06', %w(
  | when a file has lines edited
  | a kata_file_edit event 
  | shows diff_added_lines=N, diff_deleted_lines=M
  ) do
    in_tennis_kata do |id, files|
      content = files['readme.txt']['content']
      lines = content.split("\n")
      assert lines.size > 10

      lines[4] = lines[4].rstrip + "Hello world"

      files['readme.txt']['content'] = lines.join("\n")
      next_index = kata_file_edit(id, index=1, files)

      events = kata_events(id)
      assert_equal 2, next_index
      assert_equal 2, events.size

      assert_equal 1, events[1]['diff_added_count']
      assert_equal 1, events[1]['diff_deleted_count']
    end
  end

end
