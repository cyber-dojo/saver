# frozen_string_literal: true
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
    refute manifest.has_key?('version')
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
    assert_equal 1, kata_manifest(id)['version']
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
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
    assert_equal 'none', actual['predicted'], :polyfilled_predicted
    assert_equal 1, actual['index'], :polyfilled_index
  end

  # . . . . . . . . . . . .

  version_test 1, 'rp9', %w(
  retrieve already existing individual kata_event() {test-data copied into saver}
  ) do
    actual = kata_event(id='H8NAvN', index=0)

    assert actual.is_a?(Hash)
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
  kata_event(id, index=-1) retrieves the most recent event
  ) do
    id = '5rTJv5'
    actual = kata_event(id, -1)
    last = kata_event(id, 3)
    assert_equal last, actual
  end

  version_test 0, '3dJ', %w(
  kata_event(id, index=-2) retrieves the 2nd most recent event
  ) do
    id = '5rTJv5'
    actual = kata_event(id, -2)
    second_last = kata_event(id, 2)
    assert_equal second_last, actual
  end

  version_test 0, '4dJ', %w(
  |kata_event(id, index=-1) retrieves the most recent event
  |even when only the creation event exists
  ) do
    display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    id = kata_create(manifest, default_options)
    last = kata_event(id, 0)
    actual = kata_event(id, -1)
    assert_equal last, actual
  end

  # . . . . . . . . . . . .

  version_test 1, 'Hx7', %w(
  kata_event(id, index=-1) retrieves the most recent event
  ) do
    id = '5U2J18'
    actual = kata_event(id, -1)
    last = kata_event(id, 3)
    assert_equal last, actual
  end

  version_test 1, 'Hx8', %w(
  kata_event(id, index=-2) retrieves the second most recent event
  ) do
    id = '5U2J18'
    actual = kata_event(id, -2)
    second_last = kata_event(id, 2)
    assert_equal second_last, actual
  end

  version_test 1, 'Hx9', %w(
  |kata_event(id, index=-1) retrieves the most recent event
  |even when only the creation event exists
  ) do
    display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    id = kata_create(manifest, default_options)
    last = kata_event(id, 0)
    actual = kata_event(id, -1)
    assert_equal last, actual
  end

end
