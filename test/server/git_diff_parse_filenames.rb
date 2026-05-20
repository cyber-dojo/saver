require_relative 'test_base'

class GitDiffParseFilenamesTest < TestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_old_new_filenames()
  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7D5F', %w(
  | parse old & new filenames with space in both filenames
  ) do
    header = [
      'diff --git "e mpty.h" "e mpty.h"',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'e mpty.h', old_filename, :old_filename
    assert_equal 'e mpty.h', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK71B5', %w(
  | parse old & new filenames with double-quote and space in both filenames
  ) do
    # double-quote " is a legal character in a linux filename
    header = [
      'diff --git "li n\"ux" "em bed\"ded"',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'li n"ux',    old_filename, :old_filename
    assert_equal 'em bed"ded', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK750A', %w(
  | parse old & new filenames with double-quote and space only in new-filename
  ) do
    # git diff only double quotes filenames if it has to
    header = [
      'diff --git plain "em bed\"ded"',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'plain', old_filename, :old_filename
    assert_equal 'em bed"ded', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK74D8', %w(
  | parse old & new filenames with double-quote and space only in old-filename
  ) do
    # double-quote " is a legal character in a linux filename
    header = [
      'diff --git "emb ed\"ded" plain',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'emb ed"ded', old_filename, :old_filename
    assert_equal 'plain', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7740', %w(
  | new_filename is nil for for deleted file
  ) do
    header = [
      'diff --git Deleted.java Deleted.java',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'Deleted.java', old_filename, :old_filename
    assert_nil new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK72A9', %w(
  | old_filename is nil for new file
  ) do
    header = [
      'diff --git empty.h empty.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_nil old_filename, :old_filename
    assert_equal 'empty.h', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7A90', %w(
  | parse old & new filenames for renamed file
  ) do
    diff_lines = [
      'diff --git old_name.h "new \"name.h"',
      'similarity index 100%',
      'rename from old_name.h',
      'rename to new_name.h'
    ]
    old_filename, new_filename = parse_old_new_filenames(diff_lines)
    assert_equal 'old_name.h',   old_filename, :old_filename
    assert_equal 'new "name.h', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7AD7', %w(
  | parse old & new filenames for new file in nested sub-dir
  ) do
    header = [
      'diff --git 1/2/3/empty.h 1/2/3/empty.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_nil old_filename, :old_filename
    assert_equal '1/2/3/empty.h', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7AD8', %w(
  | parse old & new filenames for renamed file in nested sub-dir
  ) do
    diff_lines = [
      'diff --git 1/2/3/old_name.h 1/2/3/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 1/2/3/new_name.h'
    ]
    old_filename, new_filename = parse_old_new_filenames(diff_lines)
    assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    assert_equal '1/2/3/new_name.h', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7AD9', %w(
  | parse old & new filenames for renamed file across nested sub-dir
  ) do
    diff_lines = [
      'diff --git 1/2/3/old_name.h 4/5/6/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 4/5/6/new_name.h'
    ]
    old_filename, new_filename = parse_old_new_filenames(diff_lines)
    assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    assert_equal '4/5/6/new_name.h', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7AD0', %w(
  | parse old & new nested sub-dir filenames
  | with double-quote and space in both filenames
  ) do
    # double-quote " is a legal character in a linux filename
    header = [
      'diff --git "s/d/f/li n\"ux" "u/i/o/em bed\"ded"',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 's/d/f/li n"ux',    old_filename, :old_filename
    assert_equal 'u/i/o/em bed"ded', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7AD1', %w(
  | parse old & new nested sub-dir filenames
  | with double-quote and space in both filenames
  | and where first sub-dir is a or b which could clash
  | with git-diff output which uses a/ and b/
  ) do
    # double-quote " is a legal character in a linux filename
    header = [
      'diff --git "a/d/f/li n\"ux" "b/u/i/o/em bed\"ded"',
      'index 0000000..e69de29'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'a/d/f/li n"ux',      old_filename, :old_filename
    assert_equal 'b/u/i/o/em bed"ded', new_filename, :new_filename
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'wK7C3F', %w(
  | old_filename is nil for copied file.
  | git diff --find-copies-harder (used in gitter.rb) enables copy
  | detection across unmodified files. All empty files share the same
  | blob hash (e69de29), so when a new empty file is added alongside
  | an existing empty file, git sees two files with identical content
  | and emits copy from/to headers instead of new file mode.
  | The parser must treat this as :created, not :renamed.
  ) do
    header = [
      'diff --git empty.txt new_file.txt',
      'similarity index 100%',
      'copy from empty.txt',
      'copy to new_file.txt'
    ]
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_nil old_filename, :old_filename
    assert_equal 'new_file.txt', new_filename, :new_filename
  end

  include GitDiffParseFilenames
end
