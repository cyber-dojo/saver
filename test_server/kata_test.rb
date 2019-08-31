require_relative 'test_base'

class KataTest < TestBase

  def self.hex_prefix
    '975'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'exists? is false before creation, true after creation' do
    id = '50C8C6'
    refute kata.exists?(id)
    id_generator_stub(id)
    kid = kata.create(starter.manifest)
    assert_equal id, kid
    assert kata.exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(), manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'create() generates an id which can retrieve the manifest' do
    id = kata.create(starter.manifest)
    manifest = kata.manifest(id)
    assert_equal id, manifest.delete('id')
    assert_equal manifest, starter.manifest
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42B', %w(
  create() an individual practice-session
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
  'manifest(id) raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata.manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # ran_tests(), events(), event()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '821',
  'events(id) raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata.events(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '822',
  'event(id,n) raises when n does not exist' do
    id = kata.create(starter.manifest)
    error = assert_raises(ArgumentError) {
      kata.event(id, 1)
    }
    assert_equal 'index:invalid:1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'event(n) raises when id does exist' do
    id = '753c8C'
    error = assert_raises(ArgumentError) {
      kata.event(id, -1)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '823',
  'ran_tests(id,...) raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '824', %w(
    ran_tests(id,index,...) raises when index is -1
    because -1 can only be used on event()
  ) do
    id = kata.create(starter.manifest)
    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, -1, edited_files))
    }
    assert_equal 'index:invalid:-1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '825', %w(
    ran_tests(id,index,...) raises when index is 0
    because 0 is used for create()
  ) do
    id = kata.create(starter.manifest)
    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, 0, edited_files))
    }
    assert_equal 'index:invalid:0', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '826', %w(
    ran_tests(id,index,...) raises when index already exists
  ) do
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

    error = assert_raises(ArgumentError) {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
    assert_equal 'index:invalid:1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '827', %w(
    ran_tests(id,index,...) does NOT raise when index-1 does not exist
    and the reason for this is partly speed
    and partly robustness against temporary katas failure
  ) do
    id = kata.create(starter.manifest)
    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    # ran.tests(*make_ran_test_args(id, 2, ...)) assume failed
    kata.ran_tests(*make_ran_test_args(id, 3, edited_files)) # <====
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '829',
  'after ran_tests() there is one more event' do
    id = kata.create(starter.manifest)

    expected_events = [event0]
    diagnostic = '#0 events(id)'
    assert_equal expected_events, kata.events(id), diagnostic

    files = starter.manifest['visible_files']
    expected = { 'files' => files }
    assert_equal expected, kata.event(id, 0), 'event(id,0)'
    assert_equal expected, kata.event(id, -1), 'event(id,-1)'

    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))

    expected_events << {
      'colour' => red,
      'time' => time_now,
      'duration' => duration
    }
    diagnostic = '#1 events(id)'
    assert_equal expected_events, kata.events(id), diagnostic

    expected = rag_event(edited_files, stdout, stderr, status)
    assert_equal expected, kata.event(id, 1), 'event(id,1)'
    assert_equal expected, kata.event(id, -1), 'event(id,-1)'
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
