require_relative 'test_base'

class KataDiffV0Test < TestBase

  test 'C4dK7p', %w(
  | v0 kata: diff_lines returns line-by-line diffs between events
  ) do
    result = diff_lines(V0_KATA_ID, 2, 3)
    hiker = result.find { |d| d['new_filename'] == 'hiker.rb' }
    assert_equal 'changed', hiker['type']
    assert_equal 'hiker.rb', hiker['old_filename']
    assert_equal({ 'added' => 1, 'deleted' => 1, 'same' => 3 }, hiker['line_counts'])
    assert_equal [
      { 'type' => 'same',    'line' => '',              'number' => 1 },
      { 'type' => 'same',    'line' => 'def answer',    'number' => 2 },
      { 'type' => 'section', 'index' => 0 },
      { 'type' => 'deleted', 'line' => '  6 * 999dfdf', 'number' => 3 },
      { 'type' => 'added',   'line' => '  6 * 7',       'number' => 3 },
      { 'type' => 'same',    'line' => 'end',            'number' => 4 }
    ], hiker['lines']
  end

  test 'C4dK7q', %w(
  | v0 kata: diff_summary returns diffs without per-line detail between events
  ) do
    result = diff_summary(V0_KATA_ID, 2, 3)
    hiker = result.find { |d| d['new_filename'] == 'hiker.rb' }
    assert_equal 'changed', hiker['type']
    assert_equal 'hiker.rb', hiker['old_filename']
    assert_equal({ 'added' => 1, 'deleted' => 1, 'same' => 3 }, hiker['line_counts'])
    refute hiker.key?('lines')
  end

end
