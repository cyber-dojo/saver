require_relative 'test_base'

class AvatarForkTest < TestBase

  version_test 2, 'Af4kC1', %w(
  | avatar_fork from an avatar returns the id of a new avatar
  | in the same group
  ) do
    in_group do |gid|
      kid = group_join(gid)
      aid = avatar_fork(kid, 0)
      assert kata_exists?(aid), aid
      assert_equal gid, kata_manifest(aid)['group_id']
      assert_equal [kid, aid].sort, group_joined(gid).values.map { |kata| kata['id'] }.sort
    end
  end

end
