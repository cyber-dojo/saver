module DifferDiff

  def diff_lines(id, was_index, now_index)
    differ.diff_lines(files_at(id, was_index), files_at(id, now_index))
  end

  def diff_summary(id, was_index, now_index)
    differ.diff_summary(files_at(id, was_index), files_at(id, now_index))
  end

  private

  def files_at(id, index)
    event(id, index)['files'].transform_values { |f| f['content'] }
  end

  def differ
    @externals.differ
  end

end
