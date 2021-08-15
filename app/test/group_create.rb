require_relative 'test_base'

class GroupCreateTest < TestBase

  def self.id58_prefix
    'f27'
  end

  versions_test 'R5a', %w(
  |POST /group_create_custom(version, display_name)
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |and a matching values
  ) do
    display_name = custom_start_points.display_names.sample
    assert_group_create_custom_200(display_name)
  end

  versions_test 'R5b', %w(
  |POST /group_create(version, ltf_name, exercise_name)
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |and a matching values
  ) do
    ltf_name = languages_start_points.display_names.sample
    exercise_name = exercises_start_points.display_names.sample
    assert_group_create_200(ltf_name, exercise_name)
  end

  # - - - - - - - - - - - - - - - - - - -

  versions_test 'R5c', %w(
  |POST /group_create_custom(version, display_name)
  |with unknown display_name
  |has status 500
  ) do
    display_name = 'unknown'
    assert_group_create_custom_500(display_name)
  end

  versions_test 'R5d', %w(
  |POST /group_create(version, ltf_name, exercise_name)
  |with unknown ltf_name
  |has status 500
  ) do
    ltf_name = 'unknown'
    exercise_name = exercises_start_points.display_names.sample
    assert_group_create_500(ltf_name, exercise_name)
  end

  private

  def assert_group_create_custom_200(display_name)
    assert_json_post_200(
      path = 'group_create_custom', {
        version: version,
        display_name: display_name
      }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert_group_exists(id, display_name)
      manifest = group_manifest(id)
      assert_equal version, manifest['version']
    end
  end

  def assert_group_create_200(ltf_name, exercise_name)
    assert_json_post_200(
      path = 'group_create', {
        version: version,
        ltf_name: ltf_name,
        exercise_name: exercise_name
      }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert_group_exists(id, ltf_name, exercise_name)
      manifest = group_manifest(id)
      assert_equal version, manifest['version']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def assert_group_create_custom_500(display_name)
    assert_json_post_500(
      path='group_create_custom', {
        version: version,
        display_name: display_name
      }.to_json
    ) do |response|
      assert_equal ["exception"], response.keys, :keys
    end
  end

  def assert_group_create_500(ltf_name, exercise_name)
    assert_json_post_500(
      path='group_create', {
        version: version,
        ltf_name: ltf_name,
        exercise_name: exercise_name
      }.to_json
    ) do |response|
      assert_equal ["exception"], response.keys, :keys
    end
  end

end
