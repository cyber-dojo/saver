require_relative 'git_diff_parse_filenames'
require_relative 'git_diff_parser'

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
    cmd = [
      'git diff',
      '--unified=99999999999',
      '--no-prefix',
      '--ignore-space-at-eol',
      '--find-renames',
      '--indent-heuristic',
      was_index.to_s,
      now_index.to_s,
      '--',
      'files/'
    ].join(' ')
    diff_text = shell.assert_cd_exec(repo_dir(id), cmd)
    diffs = GitDiffParser.new(diff_text, options).parse_all
    diffs.each { |d| strip_files_prefix(d) }
    fill_identical_renamed_files(id, now_index, diffs, options)
    diffs + unchanged_files(id, now_index, diffs, options)
  end

  def strip_files_prefix(diff)
    diff[:old_filename] = strip_files(diff[:old_filename])
    diff[:new_filename] = strip_files(diff[:new_filename])
  end

  def strip_files(filename)
    return nil if filename.nil?
    filename.start_with?('files/') ? filename['files/'.size..] : filename
  end

  def fill_identical_renamed_files(id, now_index, diffs, options)
    diffs.each do |diff|
      next unless diff[:type] == :renamed && diff[:line_counts] == { same: 0, deleted: 0, added: 0 }
      lines = git_file_lines(id, now_index, diff[:new_filename])
      diff[:line_counts][:same] = lines.count
      diff[:lines] = same_lines(lines) if options[:lines]
    end
  end

  def unchanged_files(id, now_index, diffs, options)
    changed_filenames = diffs.map { |d| d[:new_filename] }
    (git_ls_files(id, now_index) - changed_filenames).map do |filename|
      lines = git_file_lines(id, now_index, filename)
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

  def git_ls_files(id, index)
    output = shell.assert_cd_exec(repo_dir(id), "git ls-tree -r --name-only #{index} -- files/")
    output.split("\n").map { |f| f['files/'.size..] }
  end

  def git_file_lines(id, index, filename)
    content = shell.assert_cd_exec(repo_dir(id), "git show #{index}:files/#{filename}")
    content.split("\n")
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
