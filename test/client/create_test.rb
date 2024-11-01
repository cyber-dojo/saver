require_relative 'test_base'

class CreateTest < TestBase

  def self.id58_prefix
    'f26'
  end

  # - - - - - - - - - - - - - - - - -

  versions_test 'q32', %w(
  |POST /group_create()
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |whose manifest matches
  ) do
    in_group do |id|
      assert group_exists?(id), :group_exists?
      m = group_manifest(id)
      assert_equal id, m['id'], :id
      assert_equal version, m['version'], :version
    end
  end

  # - - - - - - - - - - - - - - - - -

  versions_test 'q34', %w(
  |POST /kata_create()
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |whose manifest matches
  ) do
    in_kata do |id|
      assert kata_exists?(id), :group_exists?
      m = kata_manifest(id)
      assert_equal id, m['id'], :id
      assert_equal version, m['version'], :version
    end
  end

end
