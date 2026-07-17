require_relative 'test_base'

class KataStoresLaptopIdTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'La3F01', %w(
  | a kata_file_create stores the writer's laptop_id on the committed event
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    model.kata_file_create(id: id, files: files, filename: 'wibble.txt', laptop_id: LAPTOP_A)
    event = kata_event(id, 1)
    assert_equal 'file_create', event['colour']
    assert_equal LAPTOP_A, event['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'La3F02', %w(
  | a write that also commits an implicit file_edit stamps BOTH events
  | (the edit and the create) with the same laptop_id
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    edited = files.keys.first
    files[edited]['content'] += "\n# edited"
    model.kata_file_create(id: id, files: files, filename: 'wibble.txt', laptop_id: LAPTOP_B)
    events = kata_events(id)
    assert_equal 3, events.size
    assert_equal 'file_edit',   kata_event(id, 1)['colour']
    assert_equal 'file_create', kata_event(id, 2)['colour']
    assert_equal LAPTOP_B, kata_event(id, 1)['laptop_id']
    assert_equal LAPTOP_B, kata_event(id, 2)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'La3F03', %w(
  | a kata_ran_tests stores the writer's laptop_id on the committed event
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }
    model.kata_ran_tests(id: id, files: files, stdout: stdout, stderr: stderr, status: '0', summary: red_summary, laptop_id: LAPTOP_C)
    assert_equal LAPTOP_C, kata_event(id, 1)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'La3F04', %w(
  | a write with no laptop_id (nil from the outside) does NOT store a
  | laptop_id key on the event at all, leaving it indistinguishable from a
  | legacy pre-laptop_id event; the other event fields are unchanged
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    model.kata_file_create(id: id, files: files, filename: 'wibble.txt')
    event = kata_event(id, 1)
    refute event.key?('laptop_id'), event.to_json
    assert_equal 'file_create', event['colour']
    assert_equal 'wibble.txt', event['filename']
    assert_equal 1, event['index']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'La3F05', %w(
  | a write whose laptop_id is not the minted format (64 lowercase hex chars)
  | is NOT stored - only a well-formed id is trusted; a malformed one is
  | treated like an absent id (no laptop_id key on the event)
  ) do
    [
      'not-hex-at-all',
      'abc123',        # too short
      'A' * 64,        # uppercase, not lowercase hex
      'g' * 64,        # non-hex letters
      '0' * 63,        # 63 chars
      '0' * 65         # 65 chars
    ].each do |bad|
      id = kata_create(custom_manifest)
      files = kata_event(id, 0)['files']
      model.kata_file_create(id: id, files: files, filename: 'wibble.txt', laptop_id: bad)
      event = kata_event(id, 1)
      refute event.key?('laptop_id'), "stored bad laptop_id #{bad.inspect}: #{event.to_json}"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Realistic laptop_ids: SecureRandom.hex(32), as minted by the web before-hook.
  LAPTOP_A = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
  LAPTOP_B = 'ca990e850c196480e16b8f04a611297e12ea64c93766055643e0e60f8f8d51e0'
  LAPTOP_C = '37ef5ee71537279bb25b3040ba6616b5e97a7351f12ce659d798fa2841813324'

end
