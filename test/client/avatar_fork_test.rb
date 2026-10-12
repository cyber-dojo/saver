require_relative 'test_base'

class AvatarForkTest < TestBase

  version_test 2, 'Af4kC1', %w(
  | avatar_fork from an avatar's traffic-light returns the id of a new avatar
  | in the same group, which starts with that light
  ) do
    in_group do |gid|
      kid = group_join(gid)
      files = kata_event(kid, 0)['files']
      stdout = { 'content' => "1..1\nnot ok 1", 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      summary = { 'colour' => 'red', 'predicted' => 'none' }
      saver.kata_ran_tests(kid, files, stdout, stderr, 1, summary, laptop_id, next_tab_seq)
      index = kata_events(kid).last['index']

      aid = avatar_fork(kid, index)
      assert kata_exists?(aid), aid
      assert_equal gid, kata_manifest(aid)['group_id']
      assert_equal [kid, aid].sort, group_joined(gid).values.map { |kata| kata['id'] }.sort
      assert_equal 'red', kata_events(aid)[1]['colour']
    end
  end

end
