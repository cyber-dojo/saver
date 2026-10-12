require_relative 'test_base'

class AvatarForkTest < TestBase

  version_test 2, 'Af4kQ1', %w[
  | avatar_fork from an avatar's traffic-light returns the id of a new
  | avatar in the same group, whose starting files are that light's files
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        files = {
          "cyber-dojo.sh" => {
            "content" => "chmod 700 *.sh\n./test_*.sh\n"
          },
          "hiker.sh" => {
            "content" => "answer()\n{\n  echo $((6 * 7))\n}\n"
          }
        }
        stdout = {
          "content" => "1..1\nok 1 life the universe and everything",
          "truncated" => false
        }
        stderr = {
          "content" => "",
          "truncated" => false
        }
        status = "0"
        green_summary = {
          "colour" => "green",
          "duration" => 1.46448,
          "predicted" => "none",
        }
        kata_ran_tests(kid, files, stdout, stderr, status, green_summary)
        index = kata_events(kid).last['index']

        aid = avatar_fork(kid, index)

        avatar_manifest = kata_manifest(aid)
        assert_equal gid, avatar_manifest['group_id']
        refute_equal kata_manifest(kid)['group_index'], avatar_manifest['group_index']
        assert_equal [kid, aid].sort, group_joined(gid).values.map { |kata| kata['id'] }.sort
        assert_equal kata_event(kid, index)['files'], kata_event(aid, 0)['files']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Af4kQ2', %w[
  | avatar_fork from an avatar whose group already holds 64 avatars
  | returns nil and leaves the group at 64
  ] do
    in_group do |gid|
      kid = group_join(gid)
      63.times { group_join(gid) }
      assert_equal 64, group_joined(gid).size

      assert_nil avatar_fork(kid, 0)
      assert_equal 64, group_joined(gid).size
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Af4kQ3', %w[
  | avatar_fork from a kata that is not in a group
  | raises a request error naming the kata
  ] do
    in_kata do |kid|
      error = assert_raises(RequestError) { avatar_fork(kid, 0) }
      assert_equal "kata #{kid} is not in a group", error.message
    end
  end

end
