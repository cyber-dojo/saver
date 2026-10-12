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
      index = a_red_light(kid)
      63.times { group_join(gid) }
      assert_equal 64, group_joined(gid).size

      assert_nil avatar_fork(kid, index)
      assert_equal 64, group_joined(gid).size
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Af4kQ4', %w[
  | avatar_fork from a traffic-light gives the new avatar that light as its
  | first event, checked out from the avatar and index it was forked from,
  | so the new avatar opens with a traffic-light
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        files = {
          "cyber-dojo.sh" => {
            "content" => "chmod 700 *.sh\n./test_*.sh\n"
          },
          "hiker.sh" => {
            "content" => "answer()\n{\n  echo $((6 * 9))\n}\n"
          }
        }
        stdout = {
          "content" => "1..1\nnot ok 1 life the universe and everything",
          "truncated" => false
        }
        stderr = {
          "content" => "expected 42, got 54",
          "truncated" => false
        }
        status = "1"
        red_summary = {
          "colour" => "red",
          "duration" => 1.46448,
          "predicted" => "none",
        }
        kata_ran_tests(kid, files, stdout, stderr, status, red_summary)
        source = kata_events(kid).last

        aid = avatar_fork(kid, source['index'])

        events = kata_events(aid)
        assert_equal 2, events.size
        light = kata_event(aid, 1)
        assert_equal kata_event(kid, source['index'])['files'], light['files']
        assert_equal stdout, light['stdout']
        assert_equal stderr, light['stderr']
        assert_equal status, light['status']
        assert_equal 'red', events[1]['colour']
        expected_checkout = {
          'id' => kid,
          'index' => source['index'],
          'major_index' => source['major_index'],
          'minor_index' => source['minor_index'],
          'avatarIndex' => kata_manifest(kid)['group_index']
        }
        assert_equal expected_checkout, events[1]['checkout']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Af4kQ5', %w[
  | avatar_fork from an avatar's creation event, which is not a traffic-light,
  | raises a request error and adds no avatar to the group
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        error = assert_raises(RequestError) { avatar_fork(kid, 0) }
        assert_equal "kata #{kid} event 0 is not a traffic-light", error.message
        assert_equal 1, group_joined(gid).size
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Af4kQ6', %w[
  | avatar_fork from a file event, which is not a traffic-light,
  | raises a request error and adds no avatar to the group
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        files = kata_event(kid, 0)['files']
        files['readme.txt'] = { 'content' => 'Edited before any test run' }
        kata_file_edit(kid, files)
        index = kata_events(kid).last['index']
        error = assert_raises(RequestError) { avatar_fork(kid, index) }
        assert_equal "kata #{kid} event #{index} is not a traffic-light", error.message
        assert_equal 1, group_joined(gid).size
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Af4kQ7', %w[
  | avatar_fork from a pulling, timed_out, or faulty light, none of which
  | is a test result, raises a request error and adds no avatar to the group
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        files = kata_event(kid, 0)['files']
        stdout = { 'content' => '', 'truncated' => false }
        stderr = { 'content' => '', 'truncated' => false }
        %w( pulling timed_out faulty ).each do |colour|
          summary = { 'colour' => colour, 'duration' => 0.5, 'predicted' => 'none' }
          kata_ran_tests(kid, files, stdout, stderr, '0', summary)
          index = kata_events(kid).last['index']
          error = assert_raises(RequestError) { avatar_fork(kid, index) }
          assert_equal "kata #{kid} event #{index} is not a traffic-light", error.message
        end
        assert_equal 1, group_joined(gid).size
      end
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

  private

  # Gives kata id a red traffic-light and returns its event index.
  def a_red_light(id)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => "1..1\nnot ok 1", 'truncated' => false }
    stderr = { 'content' => '', 'truncated' => false }
    summary = { 'colour' => 'red', 'duration' => 1.2, 'predicted' => 'none' }
    kata_ran_tests(id, files, stdout, stderr, '1', summary)
    kata_events(id).last['index']
  end

end
