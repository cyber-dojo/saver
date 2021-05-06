# frozen_string_literal: true

module TestHelpersModel

  def group_create(manifest, options)
    id = model.group_create(manifests:[manifest], options:options)
    unquoted(id)
  end

  def group_exists?(id)
    model.group_exists?(id:id)
  end

  def group_manifest(id)
    JSON.parse(model.group_manifest(id:id))
  end

  AVATAR_INDEXES = (0..63).to_a

  def group_join(id, indexes=AVATAR_INDEXES.shuffle)
    id = model.group_join(id:id, indexes:indexes)
    id === 'null' ? nil : unquoted(id)
  end

  def group_joined(id)
    JSON.parse(model.group_joined(id:id))
  end

  def group_events(id)
    group_joined(id)
  end

  # - - - - - - - - - - - - - - -

  def kata_create(manifest, options)
    id = model.kata_create(manifest:manifest, options:options)
    unquoted(id)
  end

  def kata_exists?(id)
    model.kata_exists?(id:id)
  end

  def kata_manifest(id)
    JSON.parse(model.kata_manifest(id:id))
  end

  def katas_events(ids, indexes)
    JSON.parse(model.katas_events(ids:ids, indexes:indexes))
  end

  def kata_events(id)
    JSON.parse(model.kata_events(id:id))
  end

  def kata_event(id, index)
    JSON.parse(model.kata_event(id:id, index:index))
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
    {}
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

  # - - - - - - - - - - - - - - - - - - -

  def version
    if v_test?(0)
      return 0
    end
    if v_test?(1)
      return 1
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def v_test?(n)
    name58.start_with?("<version=#{n}>")
  end

  # - - - - - - - - - - - - - - - - - - -

  def unquoted(id)
    id[1..-2]
  end

  # - - - - - - - - - - - - - - - - - - -

  def assert_json_post_200(path, body, &block)
    stdout,stderr = capture_stdout_stderr {
      post_json '/'+path, body
    }
    assert_status 200, stdout, stderr
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(json_response_body)
  end

  def assert_json_post_500(path, body)
    stdout,stderr = capture_stdout_stderr {
      post_json '/'+path, body
    }
    assert_status 500, stdout, stderr
    assert_equal '', stderr, :stderr
    assert_equal stdout, last_response.body+"\n", :stdout
    if block_given?
      yield json_response_body
    end
  end

  def assert_status(expected, stdout, stderr)
    diagnostic = JSON.pretty_generate({
      stdout:stdout,
      stderr:stderr,
      'last_response.status': last_response.status
    })
    actual = last_response.status
    assert_equal expected, actual, diagnostic
  end


  def json_response_body
    assert_equal 'application/json', last_response.headers['Content-Type']
    JSON.parse(last_response.body)
  end

end
