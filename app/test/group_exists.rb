require_relative 'test_base'

class GroupExistsTest < TestBase

  def self.id58_prefix
    'Ws6'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '860', %w(
  |group_exists? is false,
  |for a well-formed id that does not exist
  ) do
    refute group_exists?('123AbZ')
  end

  version_test 2, '760', %w(
  |group_exists? is false,
  |for a well-formed id that does not exist
  ) do
    refute group_exists?('123AbZ')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '861', %w(
  |group_exists? is true,
  |for a well-formed id from previous group_create
  ) do
    in_group do |id|
      assert group_exists?(id), :created_in_test
    end
  end

  version_test 2, '761', %w(
  |group_exists? is true,
  |for a well-formed id from previous group_create
  ) do
    in_group do |id|
      assert group_exists?(id), :created_in_test
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '862', %w(
  |group_exists? is false,
  |for a malformed id
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

  version_test 2, '762', %w(
  |group_exists? is false,
  |for a malformed id
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

  versions_test '863', %w(
  |group_exists? raises,
  |when id is well-formed,
  |and saver is offline
  ) do
    externals.instance_exec {
      @disk = DiskExceptionRaiser.new
    }
    assert_raises {
      group_exists?('123AbZ')
    }
  end

  version_test 2, '763', %w(
  |group_exists? raises,
  |when id is well-formed,
  |and saver is offline
  ) do
    externals.instance_exec {
      @disk = DiskExceptionRaiser.new
    }
    assert_raises {
      group_exists?('123AbZ')
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '864', %w(
  |group_exists? is true
  |for id from original group
  |when there was no explicit version in the manifest
  ) do
    assert group_exists?('chy6BJ'), :original_no_explicit_version
    assert group_exists?('FxWwrr'), :original_no_explicit_version
  end

  private

  class DiskExceptionRaiser
    def method_missing(_m, *_args, &_block)
      raise self.class.name
    end
  end

end
