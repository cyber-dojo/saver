require_relative 'test_base'

class GroupJoinTest < TestBase

  def self.id58_prefix
    'Gw4'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '1s9', %w(
  group is initially empty
  ) do
    in_group do |id|
      assert_equal({}, joined(id))
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '6A5', %w(
  when you join a group you increase its size by one,
  and are a member of the group
  ) do
    in_group do |group_id|
      indexes = [15,4] + ((0..63).to_a - [15,4]).shuffle
      kata_1_id = group_join(group_id, indexes)
      assert kata_exists?(kata_1_id), kata_1_id
      kata_1_manifest = kata_manifest(kata_1_id)
      assert_equal kata_1_id, kata_1_manifest['id']
      assert_equal 15, kata_1_manifest['group_index']
      assert_equal group_id, kata_1_manifest['group_id']

      expected = {}
      expected["15"] = { "id" => kata_1_id }
      assert_equal expected, joined(group_id)

      kata_2_id = group_join(group_id, indexes)
      assert kata_exists?(kata_2_id), kata_2_id
      kata_2_manifest = kata_manifest(kata_2_id)
      assert_equal kata_2_id, kata_2_manifest['id']
      assert_equal 4, kata_2_manifest['group_index']
      assert_equal group_id, kata_2_manifest['group_id']

      expected["4"] = { "id" => kata_2_id }
      assert_equal expected, joined(group_id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '6A6', %w(
    when 64 avatars have joined the group is full
  ) do
    # Pre-created almost full groups.
    # See bin/create_almost_full_group.sh
    # See run/lib.sh copy_in_saver_test_data()
    # See test/server/data/almost_full_group.v?.tgz
    gids = {
      0 => 'AWCQdE',
      1 => 'X9UunP',
      2 => 'U8Tt6y'
    }
    gid = gids[version]
    assert group_joined(gid).size == 63, version

    last = group_join(gid)
    refute_nil last, :not_full
    assert kata_exists?(last)

    full = group_join(gid)
    assert_nil full, :full

    expected_indexes = (0..63).to_a
    actual_indexes = joined(gid).keys.map{ |key| key.to_i }
    assert_equal expected_indexes, actual_indexes.sort
  end

  private

  def joined(id)
    group_events(id).map{|group_index,v| [group_index,{"id"=>v["id"]}]}.to_h
  end

end
