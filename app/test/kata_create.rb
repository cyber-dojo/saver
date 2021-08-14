require_relative 'test_base'

class KataCreateTest < TestBase

  def self.id58_prefix
    'f26'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'h35', %w(
  |POST /kata_create_custom(display_name)
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching values
  ) do
    display_name = custom_start_points.display_names.sample
    assert_kata_create_custom_200(display_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'h36', %w(
  |POST /kata_create2(ltf_name, exercise_name)
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching values
  ) do
    ltf_name = languages_start_points.display_names.sample
    exercise_name = exercises_start_points.display_names.sample
    assert_kata_create2_200(ltf_name, exercise_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'q32', %w(
  |POST /kata_create(manifest)
  |with empty options
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching display_name
  ) do
    assert_kata_create_200({})
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'q33', %w(
  |POST /kata_create(manifest,options)
  |with good options
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching display_name
  ) do
    options = {
      "colour" => "on",
      "fork_button" => "off",
      "predict" => "on",
      "starting_info_dialog" => "off",
      "theme" => "dark"
    }
    assert_kata_create_200(options)
  end

  # - - - - - - - - - - - - - - - - - - -

  versions3_test 'x32', %w(
  |POST /kata_create(manifest,options)
  |when options arg is not a Hash
  |has status 500
  ) do
    [nil, 42, false, []].each do |bad|
      assert_kata_create_500_exception(bad, "options is not a Hash")
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  versions3_test 'x33', %w(
  |POST /kata_create(manifest,options)
  |when options has an unknown key
  |has status 500
  ) do
    error_message = 'options:{"wibble": 42} unknown key: "wibble"'
    assert_kata_create_500_exception({"wibble":42}, error_message)
  end

  # - - - - - - - - - - - - - - - - - - -

  versions3_test 'x34', %w(
  |POST /kata_create(manifest,options)
  |when options has an unknown value
  |has status 500
  ) do
    error_message = 'options:{"fork_button": 42} unknown value: 42'
    assert_kata_create_500_exception({"fork_button":42}, error_message)
  end

  private

  def assert_kata_create_custom_200(display_name)
    assert_json_post_200(
      path = 'kata_create_custom', {
        display_name: display_name
      }.to_json
    ) do |response|
      assert_equal [path], response.keys.sort, :keys
      id = response[path]
      assert_kata_exists(id, display_name)
    end
  end

  def assert_kata_create2_200(ltf_name, exercise_name)
    assert_json_post_200(
      path = 'kata_create2', {
        ltf_name: ltf_name,
        exercise_name: exercise_name
      }.to_json
    ) do |response|
      assert_equal [path], response.keys.sort, :keys
      id = response[path]
      assert_kata_exists(id, ltf_name, exercise_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def assert_kata_create_200(options)
    assert_json_post_200(
      path = 'kata_create', {
        manifest: custom_manifest,
        options: options
      }.to_json
    ) do |response|
      assert_equal [path], response.keys.sort, :keys
      id = response[path]
      assert_kata_exists(id, @display_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def assert_kata_create_500_exception(options, message)
    assert_json_post_500(
      path='kata_create', {
       manifest: custom_manifest,
       options: options
      }.to_json
    ) do |response|
      assert_equal message, response["exception"]
    end
  end

end
