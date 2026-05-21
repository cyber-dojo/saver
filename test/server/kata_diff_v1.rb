require_relative 'test_base'

class KataDiffSummaryTest < TestBase

  def initialize(arg)
    super(arg)
  end

  test 'F3D6E1', %w(
  | v1 kata: diff_lines returns line-by-line diffs between events
  ) do
    result = diff_lines(V1_KATA_ID, 1, 2)
    test_hiker = result.find { |d| d[:new_filename] == 'test_hiker.py' }
    assert_equal :changed, test_hiker[:type]
    assert_equal 'test_hiker.py', test_hiker[:old_filename]
    assert_equal({ added: 6, deleted: 0, same: 15 }, test_hiker[:line_counts])
  end

  test 'F3D6E2', %w(
  | v1 kata: diff_summary returns diffs without per-line detail between events
  ) do
    result = diff_summary(V1_KATA_ID, 1, 2)
    test_hiker = result.find { |d| d[:new_filename] == 'test_hiker.py' }
    assert_equal :changed, test_hiker[:type]
    assert_equal 'test_hiker.py', test_hiker[:old_filename]
    assert_equal({ added: 6, deleted: 0, same: 15 }, test_hiker[:line_counts])
    assert_nil test_hiker[:lines]
  end

end
