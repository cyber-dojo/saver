# frozen_string_literal: true
require_relative 'test_base'

class CreateTest < TestBase

  def self.id58_prefix
    'f26'
  end

  # - - - - - - - - - - - - - - - - -

  version_tests [0,1], 'q31', %w(
  |POST /group_create(manifest)
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |whose manifest matches the display_name
  ) do
    id = group_create(custom_manifest, default_options)
    assert group_exists?(id), :group_exists?
    m = group_manifest(id)
    assert_equal id, m['id'], :id
    assert_equal display_name, m['display_name'], :display_name
  end

  # - - - - - - - - - - - - - - - - -

  version_tests [0,1], 'q32', %w(
  |POST /kata_create(manifest)
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |whose manifest matches the display_name
  ) do
    id = kata_create(custom_manifest, default_options)
    assert kata_exists?(id), :group_exists?
    m = kata_manifest(id)
    assert_equal id, m['id'], :id
    assert_equal display_name, m['display_name'], :display_name
  end

end
