module DifferDiff

  def diff_lines(id, was_index, now_index)
    differ.diff_lines(files_at(id, was_index), files_at(id, now_index)).map { |diff| symbolize_diff(diff) }
  end

  def diff_summary(id, was_index, now_index)
    differ.diff_summary(files_at(id, was_index), files_at(id, now_index)).map { |diff| symbolize_diff(diff) }
  end

  private

  def symbolize_diff(diff)
    result = {
      type: diff['type'].to_sym,
      old_filename: diff['old_filename'],
      new_filename: diff['new_filename'],
      line_counts: {
        added: diff['line_counts']['added'],
        deleted: diff['line_counts']['deleted'],
        same: diff['line_counts']['same']
      }
    }
    result[:lines] = diff['lines'].map { |entry| symbolize_line(entry) } if diff.key?('lines')
    result
  end

  def symbolize_line(entry)
    if entry['type'] == 'section'
      { type: :section, index: entry['index'] }
    else
      { type: entry['type'].to_sym, line: entry['line'], number: entry['number'] }
    end
  end

  def files_at(id, index)
    event(id, index)['files'].transform_values { |f| f['content'] }
  end

  def differ
    @externals.differ
  end

end
