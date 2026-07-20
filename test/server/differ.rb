require_relative 'test_base'

class DifferTest < TestBase
  # Don't create a diff() method here as it interferes with MiniTest::Test!

  def self.versions_test(id58_suffix, *lines, &block)
    versions = [2] # saver's diff_lines/diff_summary only support v2
    versions.each do |version|
      version_test(version, id58_suffix, *lines, &block)
    end
  end

  def self.version_test(version, id58_suffix, *lines, &block)
    lines.unshift("<version:#{version}>")
    test("#{id58_suffix}#{version}", *lines) do
      @version = version
      instance_exec(&block)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sA2C', %w(
  | empty file is created
  ) do
    # Saver v2 uses git and its implementation currently relies on there
    # always being at least one file (cyber-dojo.sh cannot be deleted )
    @was_files = { 'xx' => 'Hello' }
    @now_files = { 'xx' => 'Hello', 'empty.h' => '' }

    assert_diff [
      :created, nil, 'empty.h', 0, 0, 0,
      []
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sA5C', %w(
  | empty file is deleted
  ) do
    @was_files = { 'empty.rb' => '' }
    @now_files = {}
    assert_diff [
      :deleted, 'empty.rb', nil, 0, 0, 0,
      []
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9s3ED', %w(
  | empty file is unchanged
  ) do
    @was_files = { 'empty.py' => '' }
    @now_files = { 'empty.py' => '' }
    assert_diff [
      :unchanged, 'empty.py', 'empty.py', 0, 0, 0,
      []
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sAA6', %w(
  | empty file is renamed 100% identical
  ) do
    @was_files = { 'plain' => '' }
    @now_files = { 'copy'  => '' }
    assert_diff [
      :renamed, 'plain', 'copy', 0, 0, 0,
      []
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sA2D', %w(
  | empty file is renamed 100% identical across dirs
  ) do
    @was_files = { 'plain'    => '' }
    @now_files = { 'a/b/copy' => '' }
    assert_diff [
      :renamed, 'plain', 'a/b/copy', 0, 0, 0,
      []
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sF2E', %w(
  | empty file has some content added
  ) do
    @was_files = { 'empty.c' => '' }
    @now_files = { 'empty.c' => "three\nlines\nadded" }
    assert_diff [
      :changed, 'empty.c', 'empty.c', 3, 0, 0,
      [
        section(0),
        added(1, 'three'),
        added(2, 'lines'),
        added(3, 'added')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sD09', %w(
  | non-empty file is created
  ) do
    # Saver v2 uses git and its implementation currently relies on there
    # always being at least one file (cyber-dojo.sh cannot be deleted )
    @was_files = { 'xx' => 'Hello' }
    @now_files = { 'xx' => 'Hello', 'non-empty.c' => 'something' }
    assert_diff [
      :created, nil, 'non-empty.c', 1, 0, 0,
      [
        section(0),
        added(1, 'something')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9s0C6', %w(
  | non-empty file is deleted
  ) do
    @was_files = { 'non-empty.h' => "two\nlines" }
    @now_files = {}
    assert_diff [
      :deleted, 'non-empty.h', nil, 0, 2, 0,
      [
        section(0),
        deleted(1, 'two'),
        deleted(2, 'lines')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9s21D', %w(
  | non-empty file is unchanged
  ) do
    @was_files = { 'non-empty.h' => '#include<stdio.h>' }
    @now_files = { 'non-empty.h' => '#include<stdio.h>' }
    assert_diff [
      :unchanged, 'non-empty.h', 'non-empty.h', 0, 0, 1,
      [
        same(1, '#include<stdio.h>')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sAA7', %w(
  | non-empty file is renamed 100% identical
  ) do
    @was_files = { 'plain' => 'xxx' }
    @now_files = { 'copy' => 'xxx' }
    assert_diff [
      :renamed, 'plain', 'copy', 0, 0, 1,
      [
        same(1, 'xxx')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sBA7', %w(
  | non-empty file is renamed 100% identical across dirs
  ) do
    @was_files = { 'a/b/plain' => "a\nb\nc\nd" }
    @now_files = { 'copy' => "a\nb\nc\nd" }
    assert_diff [
      :renamed, 'a/b/plain', 'copy', 0, 0, 4,
      [
        same(1, 'a'),
        same(2, 'b'),
        same(3, 'c'),
        same(4, 'd')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sAA8', %w(
  | non-empty file is renamed <100% identical
  ) do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_diff [
      :renamed, 'hiker.h', 'diamond.h', 1, 1, 3,
      [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9sAA9', %w(
  | non-empty file is renamed <100% identical across dirs
  ) do
    @was_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    assert_diff [
      :renamed, '1/2/hiker.h', '3/4/diamond.h', 1, 1, 3,
      [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9s4D0', %w(
  | non-empty file has some content added at the start
  ) do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "more\nsomething" }
    assert_diff [
      :changed, 'non-empty.c', 'non-empty.c', 1, 0, 1,
      [
        section(0),
        added(1, 'more'),
        same(2, 'something')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9s4D1', %w(
  | non-empty file has some content added at the end
  ) do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "something\nmore" }
    assert_diff [
      :changed, 'non-empty.c', 'non-empty.c', 1, 0, 1,
      [
        same(1, 'something'),
        section(0),
        added(2, 'more')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'C9s4D2', %w(
  | non-empty file has some content added in the middle
  ) do
    @was_files = { 'non-empty.c' => "a\nc" }
    @now_files = { 'non-empty.c' => "a\nB\nc" }
    assert_diff [
      :changed, 'non-empty.c', 'non-empty.c', 1, 0, 2,
      [
        same(1, 'a'),
        section(0),
        added(2, 'B'),
        same(3, 'c')
      ]
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'C9s4D3', %w(
  | diff-lines with a non-existent now-index raises reasonable exception
  ) do
    manifest = starter_manifest
    manifest['version'] = 2
    id = kata_create(manifest)

    ex = assert_raises(RuntimeError) do
      diff_lines(id, 1, 2)
    end
    assert_equal 'Invalid +ve index 1 [1 event]', ex.message
  end

  private

  def assert_diff(raw_expected)
    expected = expected_diff(raw_expected)
    assert_diff_lines(expected)
    expected[0].delete(:lines)
    assert_diff_summary(expected)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_diff_lines(expected)
    id, was_index, now_index = *run_diff_prepare
    diff = diff_lines(id, was_index, now_index)
    assert diff.include?(expected[0]), diagnostic('lines', expected, diff)
  end

  def assert_diff_summary(expected)
    id, was_index, now_index = *run_diff_prepare
    diff = diff_summary(id, was_index, now_index)
    assert diff.include?(expected[0]), diagnostic('summary', expected, diff)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def diagnostic(_type, expected, diff)
    [
      "#{name}:expected=#{JSON.pretty_generate(expected)}",
      "#{name}:diff=#{JSON.pretty_generate(diff)}"
    ].join("\n")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_diff_prepare
    id = kata_create(starter_manifest)
    event = kata_event(id, 0)
    event['files'].each do |filename, data|
      @was_files[filename] = data['content']
    end
    was_index = event['index'] + 1
    kata_ran_tests(id, @was_files)
    now_index = kata_events(id).size

    event['files'].each do |filename, data|
      @now_files[filename] = data['content']
    end
    _result = kata_ran_tests(id, @now_files)

    [id, was_index, now_index]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def starter_manifest
    manifest = kata_manifest('5U2J18') # from test-data copied into saver
    %w[id created group_id group_index].each { |key| manifest.delete(key) }
    manifest['version'] = @version
    manifest
  end

  # - - - - - - - - - - - - -

  def kata_ran_tests(id, files)
    model.kata_ran_tests(
      id: id,
      files: plain(files),
      stdout: { 'content' => 'this is stdout', 'truncated' => false },
      stderr: { 'content' => 'this is stderr', 'truncated' => false },
      status: '0',
      summary: { 'duration' => 0.457764, 'colour' => 'green', 'predicted' => 'none' }
    )
  end

  # - - - - - - - - - - - - -

  def plain(files)
    files.transform_values do |content|
      {
        'content' => content,
        'truncated' => false
      }
    end
  end

  # - - - - - - - - - - - - -

  def expected_diff(raw_expected)
    raw_expected.each_slice(7).to_a.map do |diff|
      { type: diff[0],
        old_filename: diff[1],
        new_filename: diff[2],
        lines: diff[6],
        line_counts: {
          added: diff[3],
          deleted: diff[4],
          same: diff[5]
        } }
    end
  end

  def section(index)
    { type: :section, index: index }
  end

  def same(number, line)
    one_line(:same, number, line)
  end

  def deleted(number, line)
    one_line(:deleted, number, line)
  end

  def added(number, line)
    one_line(:added, number, line)
  end

  def one_line(type, number, line)
    { type: type, number: number, line: line }
  end

end
