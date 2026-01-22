require_relative 'test_base'

class KataExistsTest < TestBase

  versions_test 'Ws5760', %w(
  | kata_exists? is false,
  | for a well-formed id that does not exist
  ) do
    refute kata_exists?('123AbZ')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Ws5761', %w(
  | kata_exists? is true,
  | for a well-formed id
  | from previous kata_create() or kata_create_custom()
  ) do
    in_kata do |id|
      assert kata_exists?(id), :in_kata
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Ws5762', %w(
  | kata_exists? is false,
  | for a malformed id
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

  versions_test 'Ws5764', %w(
  | kata_exists? is true
  | for id from original kata
  | when there was no explicit version in the manifest
  ) do
    assert kata_exists?('5rTJv5'), :original_no_explicit_version
    assert kata_exists?('k5ZTk0'), :original_no_explicit_version
  end

end
