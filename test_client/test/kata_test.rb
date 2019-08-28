require_relative 'test_base'

class KataTest < TestBase

  def self.hex_prefix
    '975'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  old_new_test '392',
  'kata_exists? is true after creation' do
    id = kata.create(starter.manifest)
    assert kata.exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(), manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  old_new_test '42D',
  'kata_manifest raises when id does not exist' do
    id = 'A4AB37'
    assert_service_error("id:invalid:#{id}") {
      kata.manifest(id)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  old_new_test '421',
  'kata_create() kata_manifest() round-trip' do
    id = kata.create(starter.manifest)
    manifest = starter.manifest
    manifest['id'] = id
    assert_equal manifest, kata.manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  old_new_test '42B', %w(
  kata_create() an individual practice-session
  results in a manifest that does not contain entries
  for group or index
  ) do
    id = kata.create(starter.manifest)
    manifest = kata.manifest(id)
    assert_nil manifest['group']
    assert_nil manifest['index']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # ran_tests(), events(), event()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  old_new_test '821',
  'kata_events raises when id does not exist' do
    id = 'A4AB37'
    assert_service_error("id:invalid:#{id}") {
      kata.events(id)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '822',
  'kata_event raises when n does not exist' do
    id = kata.create(starter.manifest)
    assert_service_error('index:invalid:1') {
      kata.event(id, 1)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '722',
  'kata_event raises when id does exist' do
    id = '653c8C'
    assert_service_error("id:invalid:#{id}") {
      kata.event(id, -1)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '823',
  'ran_tests raises when id does not exist' do
    id = 'A4AB37'
    assert_service_error("id:invalid:#{id}") {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '824', %w(
  kata_ran_tests raises when index is -1
  because -1 can only be used on kata_event()
  ) do
    id = kata.create(starter.manifest)
    assert_service_error('index:invalid:-1') {
      kata.ran_tests(*make_ran_test_args(id, -1, edited_files))
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '825', %w(
  kata_ran_tests raises when index is 0
  because 0 is used for kata_create()
  ) do
    id = kata.create(starter.manifest)
    assert_service_error('index:invalid:0') {
      kata.ran_tests(*make_ran_test_args(id, 0, edited_files))
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '826', %w(
  kata_ran_tests raises when index already exists
  and does not add a new event,
  in other words it fails atomically ) do
    id = kata.create(starter.manifest)
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

    assert_service_error('index:invalid:1') {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }

    assert_equal expected_events, kata.events(id)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '827', %w(
  kata_ran_tests does NOT raise when index-1 does not exist
  and the reason for this is partly speed
  and partly robustness against temporary katas failure ) do
    id = kata.create(starter.manifest)
    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    # ran.tests(*make_ran_test_args(id, 2, ...)) assume failed
    kata.ran_tests(*make_ran_test_args(id, 3, edited_files)) # <====
  end

  # - - - - - - - - - - - - - - - - - - - - -

  old_new_test '829',
  'after kata_ran_tests() there is one more event' do
    id = kata.create(starter.manifest)

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
