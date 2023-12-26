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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'ds0', %w( kata_events v2 ) do
    files = { "cyber-dojo.sh" => { "content" => "pytest *_test.rb" }}
    stdout = { "content" => "so", "truncated" => false }
    stderr = { "content" => "se", "truncated" => true }
    summary = { "colour" => "red" }
    t0 = [2021,6,12, 6,9,51,899055]
    t1 = [2021,6,12, 6,57,895675]
    t2 = [2021,6,12, 7,12,685675]
    t3 = [2021,6,12, 7,48,673675]
    externals.instance_exec { @time = TimeStub.new(t0, t1, t2, t3) }

    in_kata do |id|
      kata_ran_tests(id, 1, files, stdout, stderr,   "0", summary)
      kata_ran_tests(id, 2, files, stdout, stderr,   "0", summary)
      kata_ran_tests(id, 3, files, stdout, stderr, "137", summary)
      actual = kata_events(id)
      expected = [
        { "index" => 0, "time" => t0, "colour" => "red", "event" => "created" },
        { "index" => 1, "time" => t1, "colour" => "red" },
        { "index" => 2, "time" => t2, "colour" => "red" },
        { "index" => 3, "time" => t3, "colour" => "red" }
      ]
      assert_equal expected, actual
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'ds1', %w( saver outages are recorded as backfilled events ) do
    files = { "cyber-dojo.sh" => { "content" => "pytest *_test.rb" }}
    stdout = { "content" => "so", "truncated" => false }
    stderr = { "content" => "se", "truncated" => true }
    summary = { "colour" => "red" }
    t0 = [2021,6,12, 6,9,51,899055]
    t1 = [2021,6,12, 6,57,895675]
    t3 = [2021,6,12, 7,48,673675]
    externals.instance_exec { @time = TimeStub.new(t0, t1, t3) }

    in_kata do |id|
      kata_ran_tests(id, 1, files, stdout, stderr,   "0", summary)
      # saver outage for 2
      kata_ran_tests(id, 3, files, stdout, stderr, "137", summary)
      actual = kata_events(id)
      expected = [
        { "index" => 0, "time" => t0, "colour" => "red", "event" => "created" },
        { "index" => 1, "time" => t1, "colour" => "red" },
        { "index" => 2, "event" => "outage" },
        { "index" => 3, "time" => t3, "colour" => "red" }
      ]
      assert_equal expected, actual
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'eh4', %w( polyfill colour for index==0 ) do
    t0 = [2021,6,12, 6,9,51,899055]
    externals.instance_exec { @time = TimeStub.new(t0) }
    in_kata do |id|
      actual = kata_events(id)
      expected = [{ "index" => 0, "time" => t0, "colour" => "red", "event" => "created" }]
      assert_equal expected, actual
    end
  end

end
