module TestHelpersModel

  def group_create(manifests, options)
    model.group_create(manifests:manifests, options:options)
  end

  def group_exists?(id)
    model.group_exists?(id:id)
  end

  def group_manifest(id)
    model.group_manifest(id:id)
  end

  AVATAR_INDEXES = (0..63).to_a

  def group_join(id, indexes = AVATAR_INDEXES.shuffle)
    model.group_join(id:id, indexes:indexes)
  end

  def group_joined(id)
    model.group_joined(id:id)
  end

  def group_events(id)
    group_joined(id)
  end

  # - - - - - - - - - - - - - - -

  def kata_create(manifest, options)
    model.kata_create(manifest:manifest, options:options)
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

  def kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    model.kata_ran_tests(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    )
  end

  def kata_predicted_right(id, index, files, stdout, stderr, status, summary)
    model.kata_predicted_right(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    )
  end

  def kata_predicted_wrong(id, index, files, stdout, stderr, status, summary)
    model.kata_predicted_wrong(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    )
  end

  def kata_reverted(id, index, files, stdout, stderr, status, summary)
    model.kata_reverted(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    )
  end

  def kata_checked_out(id, index, files, stdout, stderr, status, summary)
    model.kata_checked_out(
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    )
  end

  def kata_option_get(id, name)
    model.kata_option_get(id:id, name:name)
  end

  def kata_option_set(id, name, value)
    model.kata_option_set(id:id, name:name, value:value)
  end

  def default_options
    {} # For group_create() and kata_create()
  end

  # - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - -

  def assert_group_exists(id, display_name, exercise_name='')
    refute_nil id, :id
    assert group_exists?(id), "!group_exists?(#{id})"
    manifest = group_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest.keys.sort
    assert_equal exercise_name, manifest['exercise'], :exercise
  end

  # - - - - - - - - - - - - - - -

  def assert_kata_exists(id, display_name, exercise_name='')
    refute_nil id, :id
    assert kata_exists?(id), "!kata_exists?(#{id})"
    manifest = kata_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest.keys.sort
    assert_equal exercise_name, manifest['exercise'], :exercise
  end

end
