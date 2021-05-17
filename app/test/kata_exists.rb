# frozen_string_literal: true
require_relative 'test_base'

class KataExistsTest < TestBase

  def self.id58_prefix
    'Ws5'
  end

  def id58_setup
    @display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    @custom_manifest = manifest
  end

  attr_reader :display_name, :custom_manifest

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '760', %w(
  |kata_exists? is false,
  |for a well-formed id that does not exist
  ) do
    refute kata_exists?('123AbZ')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_tests [0,1], '761', %w(
  |kata_exists? is true,
  |for a well-formed id that exists
  ) do
    id = kata_create(custom_manifest, default_options)
    assert kata_exists?(id), :created_in_test
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_tests [0,1], '762', %w(
  |kata_exists? is false,
  |for a malformed id
  ) do
    refute kata_exists?(42), 'Integer'
    refute kata_exists?(nil), 'nil'
    refute kata_exists?([]), '[]'
    refute kata_exists?({}), '{}'
    refute kata_exists?(true), 'true'
    refute kata_exists?(''), 'length == 0'
    refute kata_exists?('12345'), 'length == 5'
    refute kata_exists?('12345i'), '!id?()'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_tests [0,1], '763', %w(
  |kata_exists? raises,
  |when id is well-formed,
  |and saver is offline
  ) do
    externals.instance_exec {
      @disk = DiskExceptionRaiser.new
    }
    assert_raises {
      kata_exists?('123AbZ')
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '764', %w(
  |kata_exists? is true
  |for id from original kata
  |when there was no explicit version in the manifest
  ) do
    assert kata_exists?('5rTJv5'), :original_no_explicit_version
    assert kata_exists?('k5ZTk0'), :original_no_explicit_version
  end

  private

  class DiskExceptionRaiser
    def method_missing(_m, *_args, &_block)
      raise self.class.name
    end
  end

end
