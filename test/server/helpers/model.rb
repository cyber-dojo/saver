module TestHelpersModel

  def group_create(manifest)
    model.group_create(manifest:manifest)
  end

  def group_exists?(id)
    model.group_exists?(id:id)
  end

  def group_manifest(id)
    model.group_manifest(id:id)
  end

  def group_join(id, indexes = AVATAR_INDEXES.shuffle)
    model.group_join(id:id, indexes:indexes)
  end

  def group_joined(id)
    model.group_joined(id:id)
  end

  def group_events(id)
    group_joined(id)
  end

  def group_fork(id, index)
    model.group_fork(id:id, index:index)
  end

  def cluster_create(manifests)
    model.cluster_create(manifests:manifests)
  end

  def id_chain(id)
    model.id_chain(id:id)
  end

  def cluster_manifest(id)
    model.cluster_manifest(id:id)
  end

  def cluster_exists?(id)
    model.cluster_exists?(id:id)
  end

  AVATAR_INDEXES = (0..63).to_a

  # - - - - - - - - - - - - - - -

  def kata_create(manifest)
    model.kata_create(manifest:manifest)
  end

  def kata_exists?(id)
    model.kata_exists?(id:id)
  end

  def kata_manifest(id)
    model.kata_manifest(id:id)
  end

  def katas_events(ids, indexes)
    model.katas_events(ids:ids, indexes:indexes)
  end

  def kata_events(id)
    model.kata_events(id:id)
  end

  def kata_event(id, index)
    model.kata_event(id:id, index:index)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def kata_file_create(id, index, files, filename, laptop_id)
    model.kata_file_create(
      id:id, index:index, files:files, filename:filename, laptop_id:laptop_id
    )
  end

  def kata_file_delete(id, index, files, filename, laptop_id)
    model.kata_file_delete(
      id:id, index:index, files:files, filename:filename, laptop_id:laptop_id
    )
  end

  def kata_file_rename(id, index, files, old_filename, new_filename, laptop_id)
    model.kata_file_rename(
      id:id, index:index, files:files, old_filename:old_filename, new_filename:new_filename, laptop_id:laptop_id
    )
  end

  def kata_file_edit(id, index, files, laptop_id)
    model.kata_file_edit(
      id:id, index:index, files:files, laptop_id:laptop_id
    )
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, index, files, stdout, stderr, status, summary, laptop_id)
    model.kata_ran_tests(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id
    )
  end

  def kata_predicted_right(id, index, files, stdout, stderr, status, summary, laptop_id)
    model.kata_predicted_right(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id
    )
  end

  def kata_predicted_wrong(id, index, files, stdout, stderr, status, summary, laptop_id)
    model.kata_predicted_wrong(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id
    )
  end

  def kata_reverted(id, index, files, stdout, stderr, status, summary, laptop_id)
    model.kata_reverted(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id
    )
  end

  def kata_checked_out(id, index, files, stdout, stderr, status, summary, laptop_id)
    model.kata_checked_out(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id
    )
  end

  def kata_option_get(id, name)
    model.kata_option_get(id:id, name:name)
  end

  def kata_option_set(id, name, value)
    model.kata_option_set(id:id, name:name, value:value)
  end

  def kata_fork(id, index)
    model.kata_fork(id:id, index:index)
  end

  def diff_summary(id, was_index, now_index)
    model.diff_summary(id:id, was_index:was_index, now_index:now_index)
  end

  def diff_lines(id, was_index, now_index)
    model.diff_lines(id:id, was_index:was_index, now_index:now_index)
  end

end
