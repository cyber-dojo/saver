require_relative 'test_base'

class KataEventsTest < TestBase

  def self.id58_prefix
    'D9w'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'f5S', %w(
  already existing kata_events() summary {test-data copied into saver}
  is "polyfilled" to make it look like version=1
  ) do
    id = '5rTJv5'
    manifest = kata_manifest(id)
    assert_equal 0, manifest["version"], :version
    actual = kata_events(id)
    expected = [
      { "index" => 0, "event" => "created", "time" => [2019,1,16,12,44,55,800239] },
      { "index" => 1, "colour" => "red",    "time" => [2019,1,16,12,45,40,544806], "duration" => 1.46448,  "predicted" => "red" },
      { "index" => 2, "colour" => "amber",  "time" => [2019,1,16,12,45,46,82887],  "duration" => 1.031421, "predicted" => "none" },
      { "index" => 3, "colour" => "green",  "time" => [2019,1,16,12,45,52,220587], "duration" => 1.042027, "predicted" => "none" },
    ]
    assert_equal expected, actual
  end

  # . . . . . . . . . . . .

  version_test 1, 'rp8', %w(
  already existing kata_events() summary {test-data copied into saver}
  ) do
    id = '5U2J18'
    assert_equal 1, kata_manifest(id)['version'], :version
    actual = kata_events(id)
    expected = [
      { "index" => 0, "event"  => "created", "time" => [2020,10,19,12,52,46,396907]},
      { "index" => 1, "colour" => "red",     "time" => [2020,10,19,12,52,54,772809], "duration" => 0.491393, "predicted" => "none" },
      { "index" => 2, "colour" => "amber",   "time" => [2020,10,19,12,52,58,547002], "duration" => 0.426736, "predicted" => "none" },
      { "index" => 3, "colour" => "green",   "time" => [2020,10,19,12,53,3,256202],  "duration" => 0.438522, "predicted" => "none" }
    ]
    assert_equal expected, actual
  end

end
