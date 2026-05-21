require_relative 'test_base'

class KataDiffLinesTest < TestBase

  def initialize(arg)
    super(arg)
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
  | v0 kata: diff_summary returns diffs without per-line detail between events
  ) do
    result = diff_summary(V0_KATA_ID, 2, 3)
    hiker = result.find { |d| d[:new_filename] == 'hiker.rb' }
    assert_equal :changed, hiker[:type]
    assert_equal 'hiker.rb', hiker[:old_filename]
    assert_equal({ added: 1, deleted: 1, same: 3 }, hiker[:line_counts])
    assert_nil hiker[:lines]
  end

end
