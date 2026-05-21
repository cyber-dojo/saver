require_relative 'test_base'

class KataDiffLinesTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  test 'F3D6F1', %w(
  | v0 kata: diff_lines returns line-by-line diffs between events
  ) do
    result = diff_lines(V0_KATA_ID, 2, 3)
    hiker = result.find { |d| d[:new_filename] == 'hiker.rb' }
    assert_equal :changed, hiker[:type]
    assert_equal 'hiker.rb', hiker[:old_filename]
    assert_equal({ added: 1, deleted: 1, same: 3 }, hiker[:line_counts])
  end

  test 'F3D6F2', %w(
  | v1 kata: diff_lines returns line-by-line diffs between events
  ) do
    result = diff_lines(V1_KATA_ID, 1, 2)
    test_hiker = result.find { |d| d[:new_filename] == 'test_hiker.py' }
    assert_equal :changed, test_hiker[:type]
    assert_equal 'test_hiker.py', test_hiker[:old_filename]
    assert_equal({ added: 6, deleted: 0, same: 15 }, test_hiker[:line_counts])
  end

  test 'F3D6F3', %w(
  | v2 kata: diff_lines when cyber-dojo.sh has 2 lines added
  | returns changed entry with line-by-line entries
  | and unchanged entries for the other 3 files
  ) do
    in_tennis_kata do |id, files|
      original_content = files['cyber-dojo.sh']['content']
      files['cyber-dojo.sh']['content'] = original_content + "Hello\nWorld\n"
      kata_file_edit(id, 1, files)

      result = diff_lines(id, 0, 1)

      sh = result.find { |d| d[:new_filename] == 'cyber-dojo.sh' }
      assert_equal :changed, sh[:type]
      assert_equal 'cyber-dojo.sh', sh[:old_filename]
      assert_equal({ added: 2, deleted: 0, same: 1 }, sh[:line_counts])
      assert_equal [
        { type: :same,    line: 'python -m unittest *test*.py', number: 1 },
        { type: :section, index: 0 },
        { type: :added,   line: 'Hello',                        number: 2 },
        { type: :added,   line: 'World',                        number: 3 }
      ], sh[:lines]

      unchanged = result.select { |d| d[:type] == :unchanged }
      assert_equal 3, unchanged.count
    end
  end

end
