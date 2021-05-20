require_relative 'test_base'

class KataCreateTest < TestBase

  def self.id58_prefix
    'f26'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'q32', %w(
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

  versions_test 'q33', %w(
  |POST /kata_create(manifest)
  |with good options
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |with a matching display_name
  ) do
    on_off = [ "on", "off" ]
    { "colour" => on_off,
      "fork_button" => on_off,
      "predict" => on_off,
      "starting_info_dialog" => on_off,
      "theme" => ["dark","light"]
    }.each do |key,values|
      values.each do |value|
        options = { key => value }
        manifest = assert_kata_create_200(options)
        assert_equal value, manifest[key]
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  versions_test 'x32', %w(
  |POST /kata_create(manifest,options)
  |with options not a Hash
  |has status 500
  ) do
    [nil, 42, false, []].each do |bad|
      assert_kata_create_500_exception(bad, "options is not a Hash")
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  versions_test 'x33', %w(
  |POST /kata_create(manifest,options)
  |with unknown option key
  |has status 500
  ) do
    error_message = 'options:{"wibble": 42} unknown key: "wibble"'
    assert_kata_create_500_exception({"wibble":42}, error_message)
  end

  # - - - - - - - - - - - - - - - - - - -

  versions_test 'x34', %w(
  |POST /kata_create(manifest,options)
  |with unknown option value
  |has status 500
  ) do
    error_message = 'options:{"fork_button": 42} unknown value: 42'
    assert_kata_create_500_exception({"fork_button":42}, error_message)
  end

  private

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
      @manifest = kata_manifest(id)
      assert_equal version, @manifest['version'], :version
    end
    @manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def assert_kata_create_500_exception(options, message)
    assert_json_post_500(
      path='kata_create', {
       manifest: custom_manifest,
       options: options
      }.to_json
    ) do |response|
      assert_equal message, response["exception"]["message"]
    end
  end

end
