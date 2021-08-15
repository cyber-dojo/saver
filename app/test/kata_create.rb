require_relative 'test_base'

class KataCreateTest < TestBase

  def self.id58_prefix
    'f26'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'h35', %w(
  |POST /kata_create_custom(version, display_name)
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching values
  ) do
    display_name = custom_start_points.display_names.sample
    assert_kata_create_custom_200(version, display_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'h36', %w(
  |POST /kata_create(version, ltf_name, exercise_name)
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching values
  ) do
    ltf_name = languages_start_points.display_names.sample
    exercise_name = exercises_start_points.display_names.sample
    assert_kata_create_200(version, ltf_name, exercise_name)
  end

  versions_test 'h37', %w(
  |POST /kata_create(version, ltf_name, exercise_name)
  |with empty-string exercise_name
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching values
  ) do
    ltf_name = languages_start_points.display_names.sample
    assert_kata_create_200(version, ltf_name, '')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'h38', %w(
  |POST /kata_create_custom(version, display_name)
  |with unknown display_name
  |has status 500
  ) do
    display_name = 'unknown'
    assert_kata_create_custom_500(display_name)
  end

  versions3_test 'h39', %w(
  |POST /kata_create(version, ltf_name, exercise_name)
  |with unknown ltf_name
  |has status 500
  ) do
    ltf_name = 'unknown'
    exercise_name = exercises_start_points.display_names.sample
    assert_kata_create_500(ltf_name, exercise_name)
  end

  private

  def assert_kata_create_custom_200(version, display_name)
    assert_json_post_200(
      path = 'kata_create_custom', {
        version: version,
        display_name: display_name
      }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert_kata_exists(id, display_name)
      manifest = kata_manifest(id)
      assert_equal version, manifest['version'], :version
    end
  end

  def assert_kata_create_200(version, ltf_name, exercise_name)
    assert_json_post_200(
      path = 'kata_create', {
        version: version,
        ltf_name: ltf_name,
        exercise_name: exercise_name
      }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert_kata_exists(id, ltf_name, exercise_name)
      manifest = kata_manifest(id)
      assert_equal version, manifest['version'], :version
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def assert_kata_create_custom_500(display_name)
    assert_json_post_500(
      path='kata_create_custom', {
        display_name: display_name
      }.to_json
    ) do |response|
      assert_equal ["exception"], response.keys, :keys
    end
  end

  def assert_kata_create_500(ltf_name, exercise_name)
    assert_json_post_500(
      path='kata_create', {
        version: version,
        ltf_name: ltf_name,
        exercise_name: exercise_name
      }.to_json
    ) do |response|
      assert_equal ["exception"], response.keys, :keys
    end
  end

end
