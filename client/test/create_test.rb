require_relative 'test_base'

class CreateTest < TestBase

  def self.id58_prefix
    'f26'
  end

  # - - - - - - - - - - - - - - - - -

  versions_test 'q31', %w(
  |POST /group_create_custom()
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |whose manifest matches
  ) do
    in_group_custom do |id, display_name|
      assert group_exists?(id), :group_exists?
      m = group_manifest(id)
      assert_equal id, m['id'], :id
      assert_equal version, m['version'], :version
      assert_equal display_name, m['display_name'], :display_name
      assert_equal '', m['exercise'], :no_exercise
    end
  end

  versions_test 'q32', %w(
  |POST /group_create()
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  |whose manifest matches
  ) do
    in_group do |id, ltf_name, exercise_name|
      assert group_exists?(id), :group_exists?
      m = group_manifest(id)
      assert_equal id, m['id'], :id
      assert_equal version, m['version'], :version
      assert_equal ltf_name, m['display_name'], :display_name
      assert_equal exercise_name, m['exercise'], :exercise
    end
  end

  # - - - - - - - - - - - - - - - - -

  versions_test 'q33', %w(
  |POST /kata_create_custom()
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |whose manifest matches
  ) do
    in_kata_custom do |id, display_name|
      assert kata_exists?(id), :group_exists?
      m = kata_manifest(id)
      assert_equal id, m['id'], :id
      assert_equal version, m['version'], :version
      assert_equal display_name, m['display_name'], :display_name
      assert_equal '', m['exercise'], :no_exercise
    end
  end

  versions_test 'q34', %w(
  |POST /kata_create()
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  |whose manifest matches
  ) do
    in_kata do |id, ltf_name, exercise_name|
      assert kata_exists?(id), :group_exists?
      m = kata_manifest(id)
      assert_equal id, m['id'], :id
      assert_equal version, m['version'], :version
      assert_equal ltf_name, m['display_name'], :display_name
      assert_equal exercise_name, m['exercise'], :exercise
    end
  end

end
