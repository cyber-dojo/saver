require_relative 'test_base'

class KataDiffV2Test < TestBase

  version_test 2, 'M3nQ5p', %w(
  | v2 kata: diff when cyber-dojo.sh has 2 lines added
  | returns changed entry with correct line-by-line detail
  | and unchanged entries for the other 3 files
  ) do
    in_tennis_kata do |id, files|
      original_content = files['cyber-dojo.sh']['content']
      files['cyber-dojo.sh']['content'] = original_content + "Hello\nWorld\n"
      kata_file_edit(id, files, laptop_id)
      assert_diff(id, 0, 1, {
        'type'         => 'changed',
        'old_filename' => 'cyber-dojo.sh',
        'new_filename' => 'cyber-dojo.sh',
        'line_counts'  => { 'added' => 2, 'deleted' => 0, 'same' => 1 },
        'lines'        => [
          { 'type' => 'same',    'line' => 'python -m unittest *test*.py', 'number' => 1 },
          { 'type' => 'section', 'index' => 0 },
          { 'type' => 'added',   'line' => 'Hello',                        'number' => 2 },
          { 'type' => 'added',   'line' => 'World',                        'number' => 3 }
        ]
      })
      unchanged = diff_summary(id, 0, 1).select { |d| d['type'] == 'unchanged' }
      assert_equal 3, unchanged.count
    end
  end

  version_test 2, 'N4pA1', %w(
  | v2 kata: empty file is created
  ) do
    @was_files = { 'xx' => 'Hello' }
    @now_files = { 'xx' => 'Hello', 'empty.h' => '' }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'created',
      'old_filename' => nil,
      'new_filename' => 'empty.h',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
      'lines'        => []
    })
  end

  version_test 2, 'N4pA2', %w(
  | v2 kata: empty file is deleted
  ) do
    @was_files = { 'xx' => 'Hello', 'empty.h' => '' }
    @now_files = { 'xx' => 'Hello' }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'deleted',
      'old_filename' => 'empty.h',
      'new_filename' => nil,
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
      'lines'        => []
    })
  end

  version_test 2, 'N4pA3', %w(
  | v2 kata: empty file is unchanged
  ) do
    @was_files = { 'xx' => 'Hello', 'empty.h' => '' }
    @now_files = { 'xx' => 'Hello', 'empty.h' => '' }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'unchanged',
      'old_filename' => 'empty.h',
      'new_filename' => 'empty.h',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
      'lines'        => []
    })
  end

  version_test 2, 'N4pA4', %w(
  | v2 kata: empty file is renamed 100%
  ) do
    @was_files = { 'xx' => 'Hello', 'empty.h' => '' }
    @now_files = { 'xx' => 'Hello', 'empty.hpp' => '' }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'renamed',
      'old_filename' => 'empty.h',
      'new_filename' => 'empty.hpp',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
      'lines'        => []
    })
  end

  version_test 2, 'N4pA5', %w(
  | v2 kata: empty file is renamed 100% across dirs
  ) do
    @was_files = { 'xx' => 'Hello', 'src/empty.h' => '' }
    @now_files = { 'xx' => 'Hello', 'include/empty.h' => '' }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'renamed',
      'old_filename' => 'src/empty.h',
      'new_filename' => 'include/empty.h',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
      'lines'        => []
    })
  end

  version_test 2, 'N4pA6', %w(
  | v2 kata: content is added to empty file
  ) do
    @was_files = { 'xx' => 'Hello', 'empty.h' => '' }
    @now_files = { 'xx' => 'Hello', 'empty.h' => "Hello\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'changed',
      'old_filename' => 'empty.h',
      'new_filename' => 'empty.h',
      'line_counts'  => { 'added' => 1, 'deleted' => 0, 'same' => 0 },
      'lines'        => [
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'added',   'line' => 'Hello', 'number' => 1 }
      ]
    })
  end

  version_test 2, 'N4pB1', %w(
  | v2 kata: non-empty file is created
  ) do
    @was_files = { 'xx' => 'Hello' }
    @now_files = { 'xx' => 'Hello', 'new.rb' => "def answer\n  42\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'created',
      'old_filename' => nil,
      'new_filename' => 'new.rb',
      'line_counts'  => { 'added' => 3, 'deleted' => 0, 'same' => 0 },
      'lines'        => [
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'added',   'line' => 'def answer', 'number' => 1 },
        { 'type' => 'added',   'line' => '  42',        'number' => 2 },
        { 'type' => 'added',   'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pB2', %w(
  | v2 kata: non-empty file is deleted
  ) do
    @was_files = { 'xx' => 'Hello', 'old.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello' }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'deleted',
      'old_filename' => 'old.rb',
      'new_filename' => nil,
      'line_counts'  => { 'added' => 0, 'deleted' => 3, 'same' => 0 },
      'lines'        => [
        { 'type' => 'section',  'index' => 0 },
        { 'type' => 'deleted',  'line' => 'def answer', 'number' => 1 },
        { 'type' => 'deleted',  'line' => '  42',        'number' => 2 },
        { 'type' => 'deleted',  'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pB3', %w(
  | v2 kata: non-empty file is unchanged
  ) do
    @was_files = { 'xx' => 'Hello', 'same.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'same.rb' => "def answer\n  42\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'unchanged',
      'old_filename' => 'same.rb',
      'new_filename' => 'same.rb',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 3 },
      'lines'        => [
        { 'type' => 'same', 'line' => 'def answer', 'number' => 1 },
        { 'type' => 'same', 'line' => '  42',        'number' => 2 },
        { 'type' => 'same', 'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pB4', %w(
  | v2 kata: non-empty file is renamed 100%
  ) do
    @was_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'answer2.rb' => "def answer\n  42\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'renamed',
      'old_filename' => 'answer.rb',
      'new_filename' => 'answer2.rb',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 3 },
      'lines'        => [
        { 'type' => 'same', 'line' => 'def answer', 'number' => 1 },
        { 'type' => 'same', 'line' => '  42',        'number' => 2 },
        { 'type' => 'same', 'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pB5', %w(
  | v2 kata: non-empty file is renamed 100% across dirs
  ) do
    @was_files = { 'xx' => 'Hello', 'src/answer.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'lib/answer.rb' => "def answer\n  42\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'renamed',
      'old_filename' => 'src/answer.rb',
      'new_filename' => 'lib/answer.rb',
      'line_counts'  => { 'added' => 0, 'deleted' => 0, 'same' => 3 },
      'lines'        => [
        { 'type' => 'same', 'line' => 'def answer', 'number' => 1 },
        { 'type' => 'same', 'line' => '  42',        'number' => 2 },
        { 'type' => 'same', 'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pB6', %w(
  | v2 kata: non-empty file is renamed less than 100%
  ) do
    @was_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'answer2.rb' => "def answer\n  43\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'renamed',
      'old_filename' => 'answer.rb',
      'new_filename' => 'answer2.rb',
      'line_counts'  => { 'added' => 1, 'deleted' => 1, 'same' => 2 },
      'lines'        => [
        { 'type' => 'same',    'line' => 'def answer', 'number' => 1 },
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'deleted', 'line' => '  42',        'number' => 2 },
        { 'type' => 'added',   'line' => '  43',        'number' => 2 },
        { 'type' => 'same',    'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pB7', %w(
  | v2 kata: non-empty file is renamed less than 100% across dirs
  ) do
    @was_files = { 'xx' => 'Hello', 'src/answer.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'lib/answer.rb' => "def answer\n  43\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'renamed',
      'old_filename' => 'src/answer.rb',
      'new_filename' => 'lib/answer.rb',
      'line_counts'  => { 'added' => 1, 'deleted' => 1, 'same' => 2 },
      'lines'        => [
        { 'type' => 'same',    'line' => 'def answer', 'number' => 1 },
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'deleted', 'line' => '  42',        'number' => 2 },
        { 'type' => 'added',   'line' => '  43',        'number' => 2 },
        { 'type' => 'same',    'line' => 'end',          'number' => 3 }
      ]
    })
  end

  version_test 2, 'N4pC1', %w(
  | v2 kata: content is added at the start of a file
  ) do
    @was_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'answer.rb' => "# new line\ndef answer\n  42\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'changed',
      'old_filename' => 'answer.rb',
      'new_filename' => 'answer.rb',
      'line_counts'  => { 'added' => 1, 'deleted' => 0, 'same' => 3 },
      'lines'        => [
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'added',   'line' => '# new line',  'number' => 1 },
        { 'type' => 'same',    'line' => 'def answer',   'number' => 2 },
        { 'type' => 'same',    'line' => '  42',          'number' => 3 },
        { 'type' => 'same',    'line' => 'end',            'number' => 4 }
      ]
    })
  end

  version_test 2, 'N4pC2', %w(
  | v2 kata: content is added at the end of a file
  ) do
    @was_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\n  42\nend\n" }
    @now_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\n  42\nend\n# new line\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'changed',
      'old_filename' => 'answer.rb',
      'new_filename' => 'answer.rb',
      'line_counts'  => { 'added' => 1, 'deleted' => 0, 'same' => 3 },
      'lines'        => [
        { 'type' => 'same',    'line' => 'def answer', 'number' => 1 },
        { 'type' => 'same',    'line' => '  42',        'number' => 2 },
        { 'type' => 'same',    'line' => 'end',          'number' => 3 },
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'added',   'line' => '# new line',  'number' => 4 }
      ]
    })
  end

  version_test 2, 'N4pC3', %w(
  | v2 kata: content is added in the middle of a file
  ) do
    @was_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\nend\n" }
    @now_files = { 'xx' => 'Hello', 'answer.rb' => "def answer\n  42\nend\n" }
    id, was_index, now_index = run_diff_prepare
    assert_diff(id, was_index, now_index, {
      'type'         => 'changed',
      'old_filename' => 'answer.rb',
      'new_filename' => 'answer.rb',
      'line_counts'  => { 'added' => 1, 'deleted' => 0, 'same' => 2 },
      'lines'        => [
        { 'type' => 'same',    'line' => 'def answer', 'number' => 1 },
        { 'type' => 'section', 'index' => 0 },
        { 'type' => 'added',   'line' => '  42',        'number' => 2 },
        { 'type' => 'same',    'line' => 'end',          'number' => 3 }
      ]
    })
  end

  private

  def assert_diff(id, was_index, now_index, expected)
    assert_includes diff_lines(id, was_index, now_index), expected
    assert_includes diff_summary(id, was_index, now_index), expected.reject { |k, _| k == 'lines' }
  end

  def run_diff_prepare
    id = kata_create(custom_manifest)
    files0 = kata_event(id, 0)['files'].transform_values { |f| f['content'] }
    was = files0.merge(@was_files)
    was['cyber-dojo.sh'] = files0['cyber-dojo.sh'] + "\n# was"
    now = files0.merge(@now_files)
    now['cyber-dojo.sh'] = files0['cyber-dojo.sh'] + "\n# now"
    kata_file_edit(id, plain(was), laptop_id)
    kata_file_edit(id, plain(now), laptop_id)
    [id, 1, 2]
  end

  def plain(files)
    files.transform_values { |content| { 'content' => content, 'truncated' => false } }
  end

end
