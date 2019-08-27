require_relative 'test_base'

class KataTest < TestBase

  def self.hex_prefix
    '975'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_exists?(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'kata_exists? is false before creation, true after creation' do
    id = '50C8C6'
    refute kata.exists?(id)
    stub_kata_create(id)
    assert kata.exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_create(), kata_manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'kata_create() generates an id which can retrieve the manifest' do
    id = kata.create(starter.manifest)
    manifest = kata.manifest(id)
    assert_equal id, manifest.delete('id')
    assert_equal manifest, starter.manifest
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42B', %w(
  kata_create() an individual practice-session
  results in a manifest that does not contain entries
  for group or index
  ) do
    manifest = starter.manifest
    id = kata.create(manifest)
    manifest = kata.manifest(id)
    assert_nil manifest['group']
    assert_nil manifest['index']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42D',
  'kata_manifest raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata.manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_ran_tests(id,...), kata_events(id), kata_event(id,n)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '821',
  'kata_events raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata.events(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '822',
  'kata_event raises when n does not exist' do
    id = stub_kata_create('AB5AEE')
    error = assert_raises(ArgumentError) {
      kata.event(id, 1)
    }
    assert_equal 'index:invalid:1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'kata_event raises when id does exist' do
    id = '753c8C'
    error = assert_raises(ArgumentError) {
      kata.event(id, -1)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '823',
  'ran_tests raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '824', %w(
  kata_ran_tests raises when index is -1
  because -1 can only be used on kata_event()
  ) do
    id = stub_kata_create('FCF211')
    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, -1, edited_files))
    }
    assert_equal 'index:invalid:-1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '825', %w(
  kata_ran_tests raises when index is 0
  because 0 is used for kata_create()
  ) do
    id = stub_kata_create('08739D')
    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, 0, edited_files))
    }
    assert_equal 'index:invalid:0', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '826', %w(
  kata_ran_tests raises when index already exists
  and does not add a new event,
  in other words it fails atomically ) do
    id = stub_kata_create('C7112B')
    expected_events = []
    expected_events << event0
    assert_equal expected_events, kata.events(id)

    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    expected_events << {
      'colour' => red,
      'time' => time_now,
      'duration' => duration
    }
    assert_equal expected_events, kata.events(id)

    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
    assert_equal 'index:invalid:1', error.message

    assert_equal expected_events, kata.events(id)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '827', %w(
  kata_ran_tests does NOT raise when index-1 does not exist
  and the reason for this is partly speed
  and partly robustness against temporary katas failure ) do
    id = stub_kata_create('710145')
    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    # ran.tests(*make_ran_test_args(id, 2, ...)) assume failed
    kata.ran_tests(*make_ran_test_args(id, 3, edited_files)) # <====
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '829',
  'after kata_ran_tests() there is one more event' do
    id = stub_kata_create('9DD618')

    expected_events = [event0]
    diagnostic = '#0 kata_events(id)'
    assert_equal expected_events, kata.events(id), diagnostic

    files = starter.manifest['visible_files']
    expected = { 'files' => files }
    assert_equal expected, kata.event(id, 0), 'kata_event(id,0)'
    assert_equal expected, kata.event(id, -1), 'kata_event(id,-1)'

    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))

    expected_events << {
      'colour' => red,
      'time' => time_now,
      'duration' => duration
    }
    diagnostic = '#1 kata_events(id)'
    assert_equal expected_events, kata.events(id), diagnostic

    expected = rag_event(edited_files, stdout, stderr, status)
    assert_equal expected, kata.event(id, 1), 'kata_event(id,1)'
    assert_equal expected, kata.event(id, -1), 'kata_event(id,-1)'
  end

  private

  def rag_event(files, stdout, stderr, status)
    {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
  end

end
