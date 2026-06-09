require_relative '../lib/utf8_clean'

class GitDiffBuilder
  # Builds the saver's per-file diff hashes from the structured diff produced
  # in-process by libgit2 (External::Git#diff). The input is the Array of file
  # descriptors External::Git#diff returns; the output shape is pinned by
  # test/server/kata_diff.rb:
  #   { type:, old_filename:, new_filename:,
  #     line_counts: { added:, deleted:, same: }, lines? }
  # where :lines is present only when options[:lines] is truthy. A change region
  # is bracketed by a :section marker, then its deletions (old line numbers),
  # then its additions (new line numbers); context lines are :same (new line
  # numbers). libgit2 lists deletions before additions within a region, so the
  # grouping below sees them in that order.

  def initialize(files, options)
    @files = files
    @options = options
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def build_all
    @files.map { |file| build_one(file) }
  end

  private

  def build_one(file)
    type, old_filename, new_filename = classify(file)
    one = {
      type: type,
      old_filename: old_filename,
      new_filename: new_filename,
      line_counts: counts(file[:lines])
    }
    one[:lines] = lines_of(file[:lines]) if @options[:lines]
    one
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def classify(file)
    # libgit2 sets old_file.path == new_file.path for pure adds and deletes, so
    # the absent side is keyed off the status, not the path. Only renames are
    # detected (find_similar! with rename detection, matching the old
    # --find-renames), never copies, so :copied does not occur; the else is the
    # :modified case.
    case file[:status]
    when :added   then [:created, nil,             file[:new_path]]
    when :deleted then [:deleted, file[:old_path], nil]
    when :renamed then [:renamed, file[:old_path], file[:new_path]]
    else               [:changed, file[:old_path], file[:new_path]]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def counts(lines)
    {
      added:   lines.count { |line| line[:origin] == :addition },
      deleted: lines.count { |line| line[:origin] == :deletion },
      same:    lines.count { |line| line[:origin] == :context }
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def lines_of(lines)
    out = []
    section_index = 0
    i = 0
    while i < lines.size
      while i < lines.size && lines[i][:origin] == :context
        out << source_line(:same, lines[i], lines[i][:new_lineno])
        i += 1
      end
      break unless i < lines.size
      out << { type: :section, index: section_index }
      section_index += 1
      while i < lines.size && lines[i][:origin] == :deletion
        out << source_line(:deleted, lines[i], lines[i][:old_lineno])
        i += 1
      end
      while i < lines.size && lines[i][:origin] == :addition
        out << source_line(:added, lines[i], lines[i][:new_lineno])
        i += 1
      end
    end
    out
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def source_line(type, line, number)
    { type: type, line: clean(line[:content]), number: number }
  end

  # libgit2 blob bytes arrive tagged ASCII-8BIT; clean to UTF-8 (matching the
  # old shell path, which ran Utf8.clean over the git-diff output) and drop the
  # single trailing newline the diff line carries.
  def clean(content)
    Utf8.clean(content.chomp("\n"))
  end
end
