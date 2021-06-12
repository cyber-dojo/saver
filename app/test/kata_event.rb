require_relative 'test_base'

class KataEventTest < TestBase

  def self.id58_prefix
    'Lw2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, '2R6', %w( v0 example ) do
    actual = kata_event(V0_KATA_ID, 2)
    expected = kata_event_k5ZTk0_2
    assert_equal expected, actual
    actual = kata_event(V0_KATA_ID, 3)
    expected = kata_event_k5ZTk0_3
    assert_equal expected, actual
  end

  version_test 0, '2R8', %w( v0 example via HTTP GET ) do
    args = {"id":V0_KATA_ID, "index":3 }
    expected = kata_event_k5ZTk0_3
    assert_json_get_200('kata_event', args) do |actual|
      assert_equal expected, actual
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 1, '1P3', %w( v1 example ) do
    actual = kata_event(V1_KATA_ID, 1)
    expected = kata_event_rUqcey_1
    assert_equal expected, actual
    actual = kata_event(V1_KATA_ID, 2)
    expected = kata_event_rUqcey_2
    assert_equal expected, actual
  end

  version_test 1, '1P5', %w( v1 example via HTTP GET ) do
    args = {"id":V1_KATA_ID, "index":2}
    expected = kata_event_rUqcey_2
    assert_json_get_200('kata_event', args) do |actual|
      assert_equal expected, actual
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'f5T', %w(
  retrieve already existing individual kata_event() {test-data copied into saver}
  is "polyfilled" to make it look like version=1
  ) do
    actual = kata_event(id='5rTJv5', index=0)

    assert actual.is_a?(Hash)
    assert_equal ['files','index','time','event'].sort, actual.keys.sort
    assert_equal 0, actual['index'], :polyfilled_index
    assert_equal [2019,1,16,12,44,55,800239], actual['time'], :polyfilled_time
    assert_equal 'created', actual['event'], :polyfilled_created

    actual = kata_event(id='5rTJv5', index=1)

    assert actual.is_a?(Hash)
    assert_equal ['files','stdout','stderr','status','index','time','colour','duration','predicted'].sort, actual.keys.sort
    assert_equal '1', actual['status'], :polyfilled
    assert_equal [2019,1,16,12,45,40,544806], actual['time'], :polyfilled_time
    assert_equal 1.46448, actual['duration'], :polyfilled_duration
    assert_equal 'red', actual['colour'], :polyfilled_colour
    assert_equal 'red', actual['predicted'], :polyfilled_predicted
    assert_equal 1, actual['index'], :polyfilled_index
  end

  # . . . . . . . . . . . .

  version_test 1, 'rp9', %w(
  retrieve already existing individual kata_event() {test-data copied into saver}
  ) do
    actual = kata_event(id='H8NAvN', index=0)
    assert actual.is_a?(Hash), actual.class.name
    assert_equal ['files','index','time','event'].sort, actual.keys.sort, :keys
    assert_equal 0, actual['index'], :index
    assert_equal [2020,10,19,12,15,38,644198], actual['time'], :time
    assert_equal 'created', actual['event'], :event

    actual = kata_event(id='H8NAvN', index=1)

    assert actual.is_a?(Hash)
    assert_equal ['files','stdout','stderr','status','index','time','colour','duration','predicted'].sort, actual.keys.sort, :keys
    assert_equal '1', actual['status'], :status
    assert_equal [2020,10,19,12,15,47,353545], actual['time'], :time
    assert_equal 0.918826, actual['duration'], :duration
    assert_equal 'red', actual['colour'], :colour
    assert_equal 'none', actual['predicted'], :predicted
    assert_equal 1, actual['index'], :index
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_event(id, index < 0)

  version_test 0, '2dJ', %w(
  kata_event(id, index=-N) retrieves the Nth most recent event
  ) do
    id = '5rTJv5'
    assert_equal kata_event(id, 3), kata_event(id, -1)
    assert_equal kata_event(id, 2), kata_event(id, -2)
    assert_equal kata_event(id, 1), kata_event(id, -3)
  end

  version_test 1, 'Hx7', %w(
  kata_event(id, index=-N) retrieves the Nth most recent event
  ) do
    id = '5U2J18'
    assert_equal kata_event(id, 3), kata_event(id, -1)
    assert_equal kata_event(id, 2), kata_event(id, -2)
    assert_equal kata_event(id, 1), kata_event(id, -3)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 0, '4dJ', %w(
  |kata_event(id, index=-1) retrieves the most recent event
  |even when only the creation event exists
  ) do
    display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    post_json '/kata_create', {
      manifest:manifest,
      options:default_options
    }.to_json
    id = json_response_body['kata_create']
    last = kata_event(id, 0)
    actual = kata_event(id, -1)
    assert_equal last, actual
  end
  
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, '4dK', %w(
  |kata_event(id, index) retrieving saver outage tag  
  |contains files from last real event
  |and no stdout,stderr,status
  ) do
    files = { "cyber-dojo.sh" => { "content" => "pytest *_test.rb" }}
    stdout = { "content" => "so", "truncated" => false }
    stderr = { "content" => "se", "truncated" => true }
    status = "0"
    red_summary = { "colour" => "red" }
    in_kata do |id|
      kata_ran_tests(id, index=4, files, stdout, stderr, status, red_summary)
      actual = kata_event(id, 3)
      expected = {
        "files" => files,
        "index" => 3,
        "event" => "outage"
      }
      assert_equal expected, actual
    end
  end
  
end
