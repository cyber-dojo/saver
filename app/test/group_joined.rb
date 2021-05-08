# frozen_string_literal: true
require_relative 'test_base'

class GroupJoinedTest < TestBase

  def self.id58_prefix
    'QS4'
  end

  V0_GROUP_ID = 'FxWwrr'
  V0_KATA_ID = '5rTJv5'

  V1_GROUP_ID = 'REf1t8'
  V1_KATA_ID = '5U2J18'

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0], 'JJ0', %w(
  already existing group_joined(id) {test-data copied into saver}
  with id == group-id
  ) do
    assert_equal expected[V0_GROUP_ID], group_joined(V0_GROUP_ID)
  end

  v_tests [1], 'JJ1', %w(
  already existing group_joined(id) {test-data copied into saver}
  with id == group-id
  ) do
    assert_equal expected[V1_GROUP_ID], group_joined(V1_GROUP_ID)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0], 'Sp8', %w(
  the id can be any joined kata's id
  ) do
    assert_equal expected[V0_GROUP_ID], group_joined(V0_KATA_ID)
  end

  v_tests [1], 'Sp9', %w(
  the id can be any joined kata's id
  ) do
    assert_equal expected[V1_GROUP_ID], group_joined(V1_KATA_ID)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'xD4', %w(
  empty Hash is returned for a kata-id not in a group
  ) do
    display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    id = kata_create(manifest, default_options)
    assert_equal({}, group_joined(id))
  end

  private

  def expected
    {
      V0_GROUP_ID => {
        "32" => { # mouse
          "id" => V0_KATA_ID,
          "events" => [
            { "index" => 0, "time" => [2019,1,16,12,44,55,800239], "event" => "created" },
            { "index" => 1, "time" => [2019,1,16,12,45,40,544806], "colour" => "red"  , "duration" => 1.46448,  "predicted" => "red" },
            { "index" => 2, "time" => [2019,1,16,12,45,46,82887 ], "colour" => "amber", "duration" => 1.031421, "predicted" => "none" },
            { "index" => 3, "time" => [2019,1,16,12,45,52,220587], "colour" => "green", "duration" => 1.042027, "predicted" => "none" }
          ]
        }
      },
      V1_GROUP_ID => {
        "44" => { # rhino
          "id" => V1_KATA_ID,
          "events" => [
            { "index" => 0, "time" => [2020,10,19,12,52,46,396907], "event" => "created" },
            { "index" => 1, "time" => [2020,10,19,12,52,54,772809], "duration" => 0.491393, "colour" => "red",   "predicted" => "none" },
            { "index" => 2, "time" => [2020,10,19,12,52,58,547002], "duration" => 0.426736, "colour" => "amber", "predicted" => "none" },
            { "index" => 3, "time" => [2020,10,19,12,53,3,256202],  "duration" => 0.438522, "colour" => "green", "predicted" => "none" }
          ]
        }
      }
    }
  end

end
