require_relative 'test_base'

class KataEventsTest < TestBase

  def self.id58_prefix
    'D9w'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'f5S', %w(
  | already existing kata_events() summary {test-data copied into saver}
  | is "polyfilled" to make it look like version=1
  ) do
    id = '5rTJv5'
    manifest = kata_manifest(id)
    assert_equal 0, manifest['version'], :version
    t0 = [2019,1,16,12,44,55,800239]
    t1 = [2019,1,16,12,45,40,544806]
    t2 = [2019,1,16,12,45,46,82887]
    t3 = [2019,1,16,12,45,52,220587]
    expected = [
      { 'index' => 0, 'major_index' => 0, 'minor_index' => 0, 'event' => 'created', 'time' => t0 },
      { 'index' => 1, 'major_index' => 1, 'minor_index' => 0, 'colour' => 'red',    'time' => t1, 'duration' => 1.46448,  'predicted' => 'red' },
      { 'index' => 2, 'major_index' => 2, 'minor_index' => 0, 'colour' => 'amber',  'time' => t2, 'duration' => 1.031421, 'predicted' => 'none' },
      { 'index' => 3, 'major_index' => 3, 'minor_index' => 0, 'colour' => 'green',  'time' => t3, 'duration' => 1.042027, 'predicted' => 'none' },
    ]
    actual = kata_events(id)
    assert_equal expected, actual
  end

  # . . . . . . . . . . . .

  version_test 1, 'rp8', %w(
  | already existing kata_events() summary {test-data copied into saver}
  ) do
    id = '5U2J18'
    assert_equal 1, kata_manifest(id)['version']
    t0 = [2020,10,19,12,52,46,396907]
    t1 = [2020,10,19,12,52,54,772809]
    t2 = [2020,10,19,12,52,58,547002]
    t3 = [2020,10,19,12,53,3,256202]
    expected = [
      { 'index' => 0, 'major_index' => 0, 'minor_index' => 0, 'event'  => 'created', 'time' => t0},
      { 'index' => 1, 'major_index' => 1, 'minor_index' => 0, 'colour' => 'red',     'time' => t1, 'duration' => 0.491393, 'predicted' => 'none' },
      { 'index' => 2, 'major_index' => 2, 'minor_index' => 0, 'colour' => 'amber',   'time' => t2, 'duration' => 0.426736, 'predicted' => 'none' },
      { 'index' => 3, 'major_index' => 3, 'minor_index' => 0, 'colour' => 'green',   'time' => t3, 'duration' => 0.438522, 'predicted' => 'none' }
    ]
    actual = kata_events(id)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'f5T', %w(
  | retrieve already existing individual kata_event() {test-data copied into saver}
  | is "polyfilled" to make it look like version=1
  ) do
    actual = kata_event(id='5rTJv5', index=0)

    assert actual.is_a?(Hash)
    expected = %w( files index major_index minor_index time event )
    assert_equal expected.sort, actual.keys.sort
    assert_equal 0, actual['index'], :polyfilled_index
    assert_equal [2019,1,16,12,44,55,800239], actual['time'], :polyfilled_time
    assert_equal 'created', actual['event'], :polyfilled_created

    actual = kata_event(id='5rTJv5', index=1)

    assert actual.is_a?(Hash)
    expected = %w( files stdout stderr status index major_index minor_index time colour duration predicted )
    assert_equal expected.sort, actual.keys.sort
    assert_equal '1', actual['status'], :polyfilled
    assert_equal [2019,1,16,12,45,40,544806], actual['time'], :polyfilled_time
    assert_equal 1.46448, actual['duration'], :polyfilled_duration
    assert_equal 'red', actual['colour'], :polyfilled_colour
    assert_equal 'red', actual['predicted'], :polyfilled_predicted
    assert_equal 1, actual['index'], :polyfilled_index
  end

  # . . . . . . . . . . . .

  version_test 1, 'rp9', %w(
  | retrieve already existing individual kata_event() {test-data copied into saver}
  ) do
    actual = kata_event(id='H8NAvN', index=0)

    assert actual.is_a?(Hash)
    expected = %w( files index major_index minor_index time event )
    assert_equal expected.sort, actual.keys.sort, :keys
    assert_equal 0, actual['index'], :index
    assert_equal [2020,10,19,12,15,38,644198], actual['time'], :time
    assert_equal 'created', actual['event'], :event

    actual = kata_event(id='H8NAvN', index=1)

    assert actual.is_a?(Hash)
    expected = %w( files stdout stderr status index major_index minor_index time colour duration predicted )
    assert_equal expected.sort, actual.keys.sort, :keys
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
  | kata_event(id, index=-1) retrieves the most recent event
  ) do
    id = '5rTJv5'
    actual = kata_event(id, -1)
    last = kata_event(id, 3)
    assert_equal last, actual
  end

  version_test 0, '3dJ', %w(
  | kata_event(id, index=-2) retrieves the 2nd most recent event
  ) do
    id = '5rTJv5'
    actual = kata_event(id, -2)
    second_last = kata_event(id, 2)
    assert_equal second_last, actual
  end

  version_test 0, '4dJ', %w(
  | kata_event(id, index=-1) retrieves the most recent event
  | even when only the creation event exists
  ) do
    in_kata do |id|
      last = kata_event(id, 0)
      actual = kata_event(id, -1)
      assert_equal last, actual
    end
  end

  # . . . . . . . . . . . .

  version_test 1, 'Hx7', %w(
  | kata_event(id, index=-1) retrieves the most recent event
  ) do
    id = '5U2J18'
    actual = kata_event(id, -1)
    last = kata_event(id, 3)
    assert_equal last, actual
  end

  version_test 1, 'Hx8', %w(
  | kata_event(id, index=-2) retrieves the second most recent event
  ) do
    id = '5U2J18'
    actual = kata_event(id, -2)
    second_last = kata_event(id, 2)
    assert_equal second_last, actual
  end

  version_test 1, 'Hx9', %w(
  | kata_event(id, index=-1) retrieves the most recent event
  | even when only the creation event exists
  ) do
    in_kata do |id|
      last = kata_event(id, 0)
      actual = kata_event(id, -1)
      assert_equal last, actual
    end
  end

end
