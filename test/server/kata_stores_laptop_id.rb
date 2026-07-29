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
    kata_file_create(id, files, 'wibble.txt', LAPTOP_A)
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
    kata_file_create(id, files, 'wibble.txt', LAPTOP_B)
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
    kata_ran_tests(id, files, stdout, stderr, '0', red_summary, LAPTOP_C)
    assert_equal LAPTOP_C, kata_event(id, 1)['laptop_id']
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
      kata_file_create(id, files, 'wibble.txt', bad)
      event = kata_event(id, 1)
      refute event.key?('laptop_id'), "stored bad laptop_id #{bad.inspect}: #{event.to_json}"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'La3F06', %w(
  | consecutive writes from two different laptops both append at head + 1, and
  | each event carries the laptop_id of the write that made it
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, files, stdout, stderr, '0', red_summary, LAPTOP_A)
    kata_ran_tests(id, files, stdout, stderr, '0', red_summary, LAPTOP_B)

    assert_equal 3, kata_events(id).size
    assert_equal 1, kata_event(id, 1)['index']
    assert_equal LAPTOP_A, kata_event(id, 1)['laptop_id']
    assert_equal 2, kata_event(id, 2)['index']
    assert_equal LAPTOP_B, kata_event(id, 2)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Realistic laptop_ids: SecureRandom.hex(32), as minted by the web before-hook.
  LAPTOP_A = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
  LAPTOP_B = 'ca990e850c196480e16b8f04a611297e12ea64c93766055643e0e60f8f8d51e0'
  LAPTOP_C = '37ef5ee71537279bb25b3040ba6616b5e97a7351f12ce659d798fa2841813324'

end
