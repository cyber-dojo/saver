require_relative 'test_base'

class KataDiffV1Test < TestBase

  test 'D5eL8r', %w(
  | v1 kata: diff_lines returns line-by-line diffs between events
  ) do
    result = diff_lines(V1_KATA_ID, 1, 2)
    test_hiker = result.find { |d| d['new_filename'] == 'test_hiker.py' }
    assert_equal 'changed', test_hiker['type']
    assert_equal 'test_hiker.py', test_hiker['old_filename']
    assert_equal({ 'added' => 6, 'deleted' => 0, 'same' => 15 }, test_hiker['line_counts'])
    assert_equal [
      { 'type' => 'same',    'line' => 'from hiker import global_answer, Hiker',        'number' => 1  },
      { 'type' => 'same',    'line' => 'import unittest',                               'number' => 2  },
      { 'type' => 'same',    'line' => '',                                              'number' => 3  },
      { 'type' => 'same',    'line' => '',                                              'number' => 4  },
      { 'type' => 'same',    'line' => 'class TestHiker(unittest.TestCase):',           'number' => 5  },
      { 'type' => 'same',    'line' => '',                                              'number' => 6  },
      { 'type' => 'same',    'line' => '    def test_global_function(self):',           'number' => 7  },
      { 'type' => 'same',    'line' => '        self.assertEqual(42, global_answer())', 'number' => 8  },
      { 'type' => 'same',    'line' => '',                                              'number' => 9  },
      { 'type' => 'same',    'line' => '    def test_instance_method(self):',           'number' => 10 },
      { 'type' => 'same',    'line' => '        self.assertEqual(42, Hiker().instance_answer())', 'number' => 11 },
      { 'type' => 'same',    'line' => '',                                              'number' => 12 },
      { 'type' => 'section', 'index' => 0 },
      { 'type' => 'added',   'line' => '    def test_global_function2(self):',          'number' => 13 },
      { 'type' => 'added',   'line' => '        self.assertEqual(42, global_answer())', 'number' => 14 },
      { 'type' => 'added',   'line' => '',                                              'number' => 15 },
      { 'type' => 'added',   'line' => '    def test_instance_method2(self):',          'number' => 16 },
      { 'type' => 'added',   'line' => '        self.assertEqual(42, Hiker().instance_answer())', 'number' => 17 },
      { 'type' => 'added',   'line' => '        ',                                      'number' => 18 },
      { 'type' => 'same',    'line' => '',                                              'number' => 19 },
      { 'type' => 'same',    'line' => "if __name__ == '__main__':",                   'number' => 20 },
      { 'type' => 'same',    'line' => '    unittest.main()  # pragma: no cover',      'number' => 21 }
    ], test_hiker['lines']
  end

  test 'D5eL8s', %w(
  | v1 kata: diff_summary returns diffs without per-line detail between events
  ) do
    result = diff_summary(V1_KATA_ID, 1, 2)
    test_hiker = result.find { |d| d['new_filename'] == 'test_hiker.py' }
    assert_equal 'changed', test_hiker['type']
    assert_equal 'test_hiker.py', test_hiker['old_filename']
    assert_equal({ 'added' => 6, 'deleted' => 0, 'same' => 15 }, test_hiker['line_counts'])
    refute test_hiker.key?('lines')
  end

end
