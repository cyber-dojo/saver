require_relative 'test_base'

class KataEventsTest < TestBase

  def self.id58_prefix
    'D9w'
  end

  version_test 0, 'f5S', %w(
  already existing kata_events() summary {test-data copied into saver}
  is "polyfilled" to make it look like version=1
  ) do
    id = '5rTJv5'
    manifest = kata_manifest(id)
    assert_equal 0, manifest['version'], :version
    actual = kata_events(id)
    t0 = [2019,1,16,12,44,55,800239]
    t1 = [2019,1,16,12,45,40,544806]
    t2 = [2019,1,16,12,45,46,82887]
    t3 = [2019,1,16,12,45,52,220587]
    expected = [
      { 'index' => 0, 'event' => 'created', 'time' => t0 },
      { 'index' => 1, 'colour' => 'red',    'time' => t1, 'duration' => 1.46448,  'predicted' => 'red' },
      { 'index' => 2, 'colour' => 'amber',  'time' => t2, 'duration' => 1.031421, 'predicted' => 'none' },
      { 'index' => 3, 'colour' => 'green',  'time' => t3, 'duration' => 1.042027, 'predicted' => 'none' },
    ]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - -

  version_test 1, 'rp8', %w(
  already existing kata_events() summary {test-data copied into saver}
  ) do
    id = '5U2J18'
    assert_equal 1, kata_manifest(id)['version'], :version
    actual = kata_events(id)
    t0 = [2020,10,19,12,52,46,396907]
    t1 = [2020,10,19,12,52,54,772809]
    t2 = [2020,10,19,12,52,58,547002]
    t3 = [2020,10,19,12,53,3,256202]
    d1 = 0.491393
    d2 = 0.426736
    d3 = 0.438522
    expected = [
      { 'index' => 0, 'event'  => 'created', 'time' => t0},
      { 'index' => 1, 'colour' => 'red',     'time' => t1, 'duration' => d1, 'predicted' => 'none' },
      { 'index' => 2, 'colour' => 'amber',   'time' => t2, 'duration' => d2, 'predicted' => 'none' },
      { 'index' => 3, 'colour' => 'green',   'time' => t3, 'duration' => d3, 'predicted' => 'none' }
    ]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'ds0', %w( kata_events v2 ) do
    files = { 'cyber-dojo.sh' => { 'content' => 'pytest *_test.rb' }}
    stdout = { 'content' => 'so', 'truncated' => false }
    stderr = { 'content' => 'se', 'truncated' => true }
    summary = { 'colour' => 'red' }
    t0 = [2021,6,12, 6,9,51,899055]
    t1 = [2021,6,12, 6,57,895675]
    t2 = [2021,6,12, 7,12,685675]
    t3 = [2021,6,12, 7,48,673675]
    externals.instance_exec { @time = TimeStub.new(t0, t1, t2, t3) }

    in_kata do |id|
      kata_ran_tests(id, 1, files, stdout, stderr,   '0', summary)
      kata_ran_tests(id, 2, files, stdout, stderr,   '0', summary)
      kata_ran_tests(id, 3, files, stdout, stderr, '137', summary)
      actual = kata_events(id)
      expected = [
        { 'index' => 0, 'time' => t0, 'colour' => 'create', 'event' => 'created' },
        event(1, t1, 'red', 1, 281),
        event(2, t2, 'red', 0, 0),
        event(3, t3, 'red', 0, 0)
      ]
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'eh4', %w( polyfill colour='create' for index==0 creation event ) do
    t0 = [2021,6,12, 6,9,51,899055]
    externals.instance_exec { @time = TimeStub.new(t0) }
    in_kata do |id|
      actual = kata_events(id)
      expected = [{ 'index' => 0, 'colour' => 'create', 'time' => t0, 'event' => 'created' }]
      assert_equal expected, actual
    end
  end

  private

  def event(index, time, colour, diff_added_count, diff_deleted_count)
    {
      'index' => index,
      'time' => time,
      'colour' => colour,
      'diff_added_count' => diff_added_count,
      'diff_deleted_count' => diff_deleted_count
    }
  end

end
