require_relative '../lib/utf8_clean'
require_relative 'git_diff_builder'

module GitDiff

  def diff_lines(id, was_index, now_index)
    diff_plus(id, was_index, now_index, lines: true)
  end

  def diff_summary(id, was_index, now_index)
    diff_plus(id, was_index, now_index, lines: false)
  end

  private

  def diff_plus(id, was_index, now_index, options)
    validate_diff_index(id, was_index)
    validate_diff_index(id, now_index)
    structured = git.diff(repo_dir(id), was_index, now_index)
    diffs = GitDiffBuilder.new(structured, options).build_all
    now_files = git.files_blobs(repo_dir(id), now_index)
    fill_identical_renamed_files(now_files, diffs, options)
    diffs + unchanged_files(now_files, diffs, options)
  end

  def fill_identical_renamed_files(now_files, diffs, options)
    diffs.each do |diff|
      next unless diff[:type] == :renamed && diff[:line_counts] == { same: 0, deleted: 0, added: 0 }
      lines = file_lines(now_files[diff[:new_filename]])
      diff[:line_counts][:same] = lines.count
      diff[:lines] = same_lines(lines) if options[:lines]
    end
  end

  def unchanged_files(now_files, diffs, options)
    changed_filenames = diffs.map { |d| d[:new_filename] }
    (now_files.keys - changed_filenames).map do |filename|
      lines = file_lines(now_files[filename])
      entry = {
        type: :unchanged,
        old_filename: filename,
        new_filename: filename,
        line_counts: { added: 0, deleted: 0, same: lines.count }
      }
      entry[:lines] = same_lines(lines) if options[:lines]
      entry
    end
  end

  def file_lines(content)
    Utf8.clean(content).split("\n")
  end

  def same_lines(lines)
    lines.each_with_index.map { |line, i| { type: :same, line: line, number: i + 1 } }
  end

  def validate_diff_index(id, index)
    all_events = events(id)
    unless index < all_events.size
      raise "Invalid +ve index #{index} [#{plural(all_events.size, :event)}]"
    end
  end

end
