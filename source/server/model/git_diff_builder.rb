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

  # The number of lines added, deleted and the same.
  def counts(lines)
    tally = lines.map { |line| line[:origin] }.tally
    {
      added:   tally.fetch(:addition, 0),
      deleted: tally.fetch(:deletion, 0),
      same:    tally.fetch(:context, 0)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Each of lines as a source line, a :section marker before each line
  # that starts a change region.
  def lines_of(lines)
    starts = section_starts(lines)
    lines.each_with_index.flat_map do |line, n|
      section_marker(starts, n) + [diff_line(line)]
    end
  end

  # The pairs of origins, [previous, next], whose next line is in the
  # same change region as its previous one: deletions, then additions.
  SAME_SECTION = [
    [:deletion, :deletion],
    [:deletion, :addition],
    [:addition, :addition]
  ].freeze

  # The indexes in lines of each line that starts a change region.
  def section_starts(lines)
    origins = lines.map { |line| line[:origin] }
    previous = [nil] + origins[0..-2]
    starts = []
    origins.each_index do |n|
      starts << n if starts_section?(previous[n], origins[n])
    end
    starts
  end

  # True when a line of origin, after one of previous (nil for none),
  # starts a change region.
  def starts_section?(previous, origin)
    origin != :context && !SAME_SECTION.include?([previous, origin])
  end

  # The :section marker before the line at n, when it starts the
  # change region numbered by its place in starts; none when not.
  def section_marker(starts, n)
    index = starts.index(n)
    index.nil? ? [] : [{ type: :section, index: index }]
  end

  # The source line type of each origin, and the side its number is on.
  DIFF_LINES = {
    context:  [:same,    :new_lineno],
    deletion: [:deleted, :old_lineno],
    addition: [:added,   :new_lineno]
  }.freeze

  # line as a source line: numbered on its new side, or its old side
  # when deleted; a KeyError for any other origin.
  def diff_line(line)
    type, side = DIFF_LINES.fetch(line[:origin])
    source_line(type, line, line[side])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def source_line(type, line, number)
    # Each diff line's content carries its single trailing newline.
    { type: type, line: line[:content].chomp("\n"), number: number }
  end
end
