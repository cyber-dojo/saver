require_relative 'test_base'

class KataTest < TestBase

  def self.hex_prefix
    '975'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '392',
  'exists?(id) is true with id returned from successful create()' do
    refute kata.exists?('123456')
    id = kata.create(starter.manifest)
    assert kata.exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(), manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '42D',
  'manifest() raises when id does not exist' do
    id = id_generator.id
    assert_service_error { kata.manifest(id) }
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '421',
  'create() manifest() round-trip' do
    id = kata.create(starter.manifest)
    manifest = starter.manifest
    manifest['id'] = id
    if v_test?(2)
      manifest['version'] = 2
    else
      refute manifest.has_key?('version')
    end
    assert_equal manifest, kata.manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '42B', %w(
  create() an individual practice-session
  results in a manifest that does not contain entries
  for group or index
  ) do
    id = kata.create(starter.manifest)
    manifest = kata.manifest(id)
    assert_nil manifest['group']
    assert_nil manifest['index']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # events(), event()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '821',
  'events(id) raises when id does not exist' do
    id = id_generator.id
    assert_service_error { kata.events(id) }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '822',
  'event(id,n) raises when n does not exist' do
    id = kata.create(starter.manifest)
    assert_service_error { kata.event(id, 1) }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '823',
  'event(id) raises when id does exist' do
    id = id_generator.id
    assert_service_error { kata.event(id, -1) }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '824', %w(
  given a partial saver outage
  when event(id,-1) is called
  then v0,v1 raises
  but v2 handles it correctly
  ) do
    id = kata.create(starter.manifest)
    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    # ran.tests(*make_ran_test_args(id, 2, ...)) saver outage
    # ...
    # ran.tests(*make_ran_test_args(id, 85, ...)) saver outage
    further_edited_files = { 'cyber-dojo.sh' => file('this-has-changed') }
    kata.ran_tests(*make_ran_test_args(id, 86, further_edited_files)) # <====

    if v_test?(2)
      assert_equal 'this-has-changed', kata.event(id, -1)['files']['cyber-dojo.sh']['content']
    else
      assert_raises { kata.event(id, -1) }
    end

  end

  # - - - - - - - - - - - - - - - - - - - - -
  # ran_tests()

  v_test [0,1,2], '923',
  'ran_tests(id,index,...) raises when id does not exist' do
    id = id_generator.id
    assert_service_error {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '925', %w(
  ran_tests(id,index,...) raises when index is 0
  because 0 is used for create()
  ) do
    id = kata.create(starter.manifest)
    assert_service_error {
      kata.ran_tests(*make_ran_test_args(id, 0, edited_files))
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '926', %w(
    ran_tests(id,index,...) raises when index already exists
  ) do
    id = kata.create(starter.manifest)
    expected_events = [event0]
    assert_equal expected_events, kata.events(id)

    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    event1 = {
      'colour' => red,
      'time' => time_now,
      'duration' => duration
    }
    if v_test?(2)
      event1['index'] = 1
    end
    expected_events << event1
    assert_equal expected_events, kata.events(id)

    assert_service_error {
      kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '927', %w(
  ran_tests() does NOT raise when index-1 does not exist
  and the reason for this is partly speed
  and partly robustness against temporary saver outage ) do
    id = kata.create(starter.manifest)
    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    # ran.tests(*make_ran_test_args(id, 2, ...)) assume save failed
    kata.ran_tests(*make_ran_test_args(id, 3, edited_files)) # <====
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '929',
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

    event = {
      'colour' => red,
      'time' => time_now,
      'duration' => duration
    }
    if v_test?(2)
      event['index'] = 1
    end
    expected_events << event
    diagnostic = '#1 events(id)'
    assert_equal expected_events, kata.events(id), diagnostic

    expected = rag_event(edited_files, stdout, stderr, status)
    assert_equal expected, kata.event(id, 1), 'event(id,1)'
    assert_equal expected, kata.event(id, -1), 'event(id,-1)'
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1], '930', %w(
    event-0
      has files in lined format, with no truncated field
      has no stdout/stderr/status fields
    event-N
      has files in lined-format, possibly with truncated field
      has stdout/stderr in lined format, with truncated field
      has an integer status field
  ) do
    id = kata.create(starter.manifest)
    event0_src = saver.send(*v01_event_read_cmd(id, 0))
    event0 = JSON.parse(event0_src)
    refute event0.has_key?('stdout')
    refute event0.has_key?('stderr')
    refute event0.has_key?('status')
    files = event0['files']
    assert_equal 6, files.size
    files.each do |filename,file|
      assert_in_lined_format(file)
      refute file.has_key?('truncated')
    end

    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    event1_src = saver.send(*v01_event_read_cmd(id, 1))
    event1 = JSON.parse(event1_src)
    assert event1.has_key?('stdout')
    assert event1.has_key?('stderr')
    assert event1.has_key?('status')
    assert_in_lined_format(event1['stdout'])
    assert_in_lined_format(event1['stderr'])
    assert event1['status'].is_a?(Integer)
    files = event1['files']
    assert_equal 4, files.size
    files.each do |filename,file|
      assert_in_lined_format(file)
      assert file.has_key?('truncated')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  v_test [2], '931', %w(
    event0
      has files in unlined format, with no truncated field
      has no stdout/stderr/status fields
    event-N
      has files in unlined format, possibly with truncated field
      has stdout/stderr in unlined format, with truncated field
      has an Integer status field
  ) do
    id = kata.create(starter.manifest)
    event0_src = saver.send(*v2_event_read_cmd(id, 0))
    event0 = JSON.parse(event0_src)
    refute event0.has_key?('stdout')
    refute event0.has_key?('stderr')
    refute event0.has_key?('status')
    files = event0['files']
    assert_equal 6, files.size
    files.each do |filename,file|
      refute_in_lined_format(file)
      refute file.has_key?('truncated')
    end

    kata.ran_tests(*make_ran_test_args(id, 1, edited_files))
    event1_src = saver.send(*v2_event_read_cmd(id, 1))
    event1 = JSON.parse(event1_src)
    assert event1.has_key?('stdout')
    assert event1.has_key?('stderr')
    assert event1.has_key?('status')
    refute_in_lined_format(event1['stdout'])
    refute_in_lined_format(event1['stderr'])
    assert event1['status'].is_a?(Integer)
    files = event1['files']
    assert_equal 4, files.size
    files.each do |filename,file|
      refute_in_lined_format(file)
      assert file.has_key?('truncated')
    end
  end

  private

  def v01_event_read_cmd(id, index)
    ['read', v01_event_filename(id, index)]
  end

  def v01_event_filename(id, index)
    id_path(id, index, 'event.json')
  end

  def v2_event_read_cmd(id, index)
    ['read', v2_event_filename(id,index)]
  end

  def v2_event_filename(id, index)
    id_path(id, "#{index}.event.json")
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def assert_in_lined_format(o)
    assert o.has_key?('content')
    content = o['content']
    assert content.is_a?(Array), content.class.name
    content.each do |line|
      assert line.is_a?(String), line.class.name
    end
  end

  def refute_in_lined_format(o)
    assert o.has_key?('content')
    content = o['content']
    assert content.is_a?(String), content.class.name
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def rag_event(files, stdout, stderr, status)
    {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
  end

end
