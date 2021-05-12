# frozen_string_literal: true
require_relative 'test_base'

class GroupCreateTest < TestBase

  def self.id58_prefix
    'f27'
  end

  def id58_setup
    @display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    @custom_manifest = manifest
  end

  attr_reader :display_name, :custom_manifest

  v_tests [1], 'q31', %w(
  |POST /group_create(manifest)
  |with empty options
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |with version 1
  |and a matching display_name
  ) do
    assert_group_create_200({})
  end

  # - - - - - - - - - - - - - - - - - - -

  v_tests [1], 'q32', %w(
  |POST /group_create(manifest)
  |with good options
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |with version 1
  |and a matching display_name
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
        manifest = assert_group_create_200(options)
        assert_equal value, manifest[key]
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  v_tests [1], 'x32', %w(
  |POST /group_create(manifest,options)
  |with options not a Hash
  |has status 500
  ) do
    [nil, 42, false, []].each do |bad|
      assert_group_create_500_exception(bad, "options is not a Hash")
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  v_tests [1], 'x33', %w(
  |POST /group_create(manifest,options)
  |with unknown option key
  |has status 500
  ) do
    assert_group_create_500_exception({"wibble":42}, 'options:{"wibble": 42} unknown key: "wibble"')
  end

  # - - - - - - - - - - - - - - - - - - -

  v_tests [1], 'x34', %w(
  |POST /group_create(manifest,options)
  |with unknown option value
  |has status 500
  ) do
    assert_group_create_500_exception({"fork_button":42}, 'options:{"fork_button": 42} unknown value: 42')
  end

  private

  def assert_group_create_200(options)
    assert_json_post_200(
      path = 'group_create', {
        manifests: [custom_manifest],
        options: options
      }.to_json
    ) do |response|
      assert_equal [path], response.keys.sort, :keys
      id = response[path]
      assert_group_exists(id, display_name)
      @manifest = group_manifest(id)
      assert_equal version, @manifest['version']
    end
    @manifest
  end

  def assert_group_create_500_exception(options, message)
    assert_json_post_500(
      path='group_create', {
       manifests: [custom_manifest],
       options: options
      }.to_json
    ) do |response|
      assert_equal message, response["exception"]["message"]
    end
  end

end
