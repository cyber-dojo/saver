require_relative 'test_base'

class GroupExistsTest < TestBase

  versions_test 'Ws6860', %w(
  | group_exists? is false,
  | for a well-formed id that does not exist
  ) do
    refute group_exists?('123AbZ')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Ws6861', %w(
  | group_exists? is true,
  | for a well-formed id
  | from previous group_create()
  ) do
    in_group do |id|
      assert group_exists?(id), :in_group
    end
  end

  versions_01_test 'Ws6868', %w(
  | group_exists? is true,
  | for a pre-existing v0/v1 group id
  ) do
    gids = { 0 => 'FxWwrr', 1 => 'REf1t8' }
    assert group_exists?(gids[version])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Ws6862', %w(
  | group_exists? is false,
  | for a malformed id
  ) do
    refute group_exists?(42), 'Integer'
    refute group_exists?(nil), 'nil'
    refute group_exists?([]), '[]'
    refute group_exists?({}), '{}'
    refute group_exists?(true), 'true'
    refute group_exists?(''), 'length == 0'
    refute group_exists?('12345'), 'length == 5'
    refute group_exists?('12345i'), '!id?()'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Ws6864', %w(
  | group_exists? is true
  | for id from original group
  | when there was no explicit version in the manifest
  ) do
    assert group_exists?('chy6BJ'), :original_no_explicit_version
    assert group_exists?('FxWwrr'), :original_no_explicit_version
  end

end
