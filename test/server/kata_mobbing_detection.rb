require_relative 'test_base'

class KataMobbingDetectionTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Mb7D01', %w(
  | a stale-index write whose only intervening event carries the requester's own
  | laptop_id is accepted and appended at head+1: the solo lost-response case is
  | self-lag, not mobbing, so no dialog fires.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, laptop_id)
    kata_ran_tests(id, 2, files, stdout, stderr, '0', red_summary, laptop_id)

    result = kata_ran_tests(id, 2, files, stdout, stderr, '0', red_summary, laptop_id)

    assert_equal 4, result['next_index']
    assert_equal 4, kata_events(id).size
    assert_equal 3, kata_event(id, -1)['index']
    assert_equal laptop_id, kata_event(id, -1)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Mb7D02', %w(
  | a reused index whose intervening event was written by a different laptop_id
  | is rejected as out-of-order: two laptops genuinely interfering.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, laptop_id)

    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, another_laptop_id)
    }
    assert_equal "Out of order event for #{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Mb7D03', %w(
  | a write whose index is beyond head+1 (ahead of the committed head) is
  | rejected as out-of-order: the browser claims a position that does not exist.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, laptop_id)

    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, 3, files, stdout, stderr, '0', red_summary, laptop_id)
    }
    assert_equal "Out of order event for #{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Mb7D04', %w(
  | a new laptop rotating into a kata loads fresh (index == head+1) and its write
  | is accepted with no dialog even though its laptop_id differs: the index .. head
  | range is empty, so identity is never examined (legitimate handoff).
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, laptop_id)
    kata_ran_tests(id, 2, files, stdout, stderr, '0', red_summary, laptop_id)

    result = kata_ran_tests(id, 3, files, stdout, stderr, '0', red_summary, another_laptop_id)

    assert_equal 4, result['next_index']
    assert_equal 4, kata_events(id).size
    assert_equal 3, kata_event(id, -1)['index']
    assert_equal another_laptop_id, kata_event(id, -1)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Mb7D05', %w(
  | with no laptop_id (the transitional path) a reused index is rejected as
  | out-of-order by the index check; laptop_id detection does not apply.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, nil)

    error = assert_raises(RuntimeError) {
      kata_ran_tests(id, 1, files, stdout, stderr, '0', red_summary, nil)
    }
    assert_equal "Out of order event for #{id}", error.message
  end

end
