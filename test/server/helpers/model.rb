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

  # These event-write helpers fill in laptop_id and tab_seq by default, so tests
  # not focused on them stay uncluttered: laptop_id defaults to default_laptop_id
  # and tab_seq to the per-call-incrementing next_tab_seq. Tests focused on
  # laptop_id or tab_seq pass explicit values (or call model.* directly).

  def kata_file_create(id, files, filename, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_file_create(
      id:id, files:files, filename:filename, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_file_delete(id, files, filename, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_file_delete(
      id:id, files:files, filename:filename, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_file_rename(id, files, old_filename, new_filename, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_file_rename(
      id:id, files:files, old_filename:old_filename, new_filename:new_filename, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_file_edit(id, files, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_file_edit(
      id:id, files:files, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_ran_tests(
      id:id,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_predicted_right(id, files, stdout, stderr, status, summary, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_predicted_right(
      id:id,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_predicted_wrong(
      id:id,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_reverted(id, files, stdout, stderr, status, summary, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_reverted(
      id:id,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id, tab_seq:tab_seq
    )
  end

  def kata_checked_out(id, files, stdout, stderr, status, summary, laptop_id = default_laptop_id, tab_seq = next_tab_seq)
    model.kata_checked_out(
      id:id,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary, laptop_id:laptop_id, tab_seq:tab_seq
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
