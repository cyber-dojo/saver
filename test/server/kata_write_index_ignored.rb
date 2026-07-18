require_relative 'test_base'

class KataWriteIndexIgnoredTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx001', %w(
  | A reused index whose intervening event was written by a different laptop_id is
  | accepted and appended at head+1. The saver always places an event at head+1
  | and does not reject a behind index; mobbing detection lives in the browser's
  | read-side poll, not a saver write-time check.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, files, stdout, stderr, '0', red_summary)

    result = kata_ran_tests(id, files, stdout, stderr, '0', red_summary, another_laptop_id)

    assert_equal 3, result['next_index']
    assert_equal 3, kata_events(id).size
    assert_equal 2, kata_event(id, -1)['index']
    assert_equal another_laptop_id, kata_event(id, -1)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx002', %w(
  | a write whose index is ahead of head+1 is accepted and placed at head+1, not
  | at the claimed index: the saver ignores the client index for placement and
  | always appends at head+1.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, files, stdout, stderr, '0', red_summary)

    result = kata_ran_tests(id, files, stdout, stderr, '0', red_summary)

    assert_equal 3, result['next_index']
    assert_equal 3, kata_events(id).size
    assert_equal 2, kata_event(id, -1)['index']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx003', %w(
  | a write with no laptop_id and a reused (behind) index is accepted and appended
  | at head+1: the saver ignores the client index for placement whether or not a
  | laptop_id is present.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, files, stdout, stderr, '0', red_summary, nil)

    result = kata_ran_tests(id, files, stdout, stderr, '0', red_summary, nil)

    assert_equal 3, result['next_index']
    assert_equal 3, kata_events(id).size
    assert_equal 2, kata_event(id, -1)['index']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx004', %w(
  | a behind index from the SAME laptop is accepted and appended at head+1 - the
  | same-laptop lost-response (self-lag) case, indistinguishable to the saver from
  | any other behind write.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, files, stdout, stderr, '0', red_summary)
    kata_ran_tests(id, files, stdout, stderr, '0', red_summary)

    result = kata_ran_tests(id, files, stdout, stderr, '0', red_summary)

    assert_equal 4, result['next_index']
    assert_equal 4, kata_events(id).size
    assert_equal 3, kata_event(id, -1)['index']
    assert_equal default_laptop_id, kata_event(id, -1)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx005', %w(
  | an in-order write (index == head+1) from a DIFFERENT laptop is accepted and
  | appended at head+1 - a legitimate handoff (a solo user switching laptops).
  | Laptop identity does not gate placement.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    kata_ran_tests(id, files, stdout, stderr, '0', red_summary)
    kata_ran_tests(id, files, stdout, stderr, '0', red_summary)

    result = kata_ran_tests(id, files, stdout, stderr, '0', red_summary, another_laptop_id)

    assert_equal 4, result['next_index']
    assert_equal 4, kata_events(id).size
    assert_equal 3, kata_event(id, -1)['index']
    assert_equal another_laptop_id, kata_event(id, -1)['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx006', %w(
  | the model write methods take no index: the client index is stripped at the HTTP
  | boundary (post_json) for every write, so index is not part of the model's write
  | contract. Passing index: to a write raises unknown keyword.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    error = assert_raises(ArgumentError) {
      model.kata_ran_tests(
        id: id, index: 1, files: files, stdout: stdout, stderr: stderr,
        status: '0', summary: red_summary, laptop_id: default_laptop_id
      )
    }
    assert_includes error.message, 'unknown keyword: :index'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx007', %w(
  | the commit message's index is generated by the saver (the placed position),
  | not taken from the caller: a write that omits the index still tags the event
  | with a message that leads with the saver-assigned index.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }

    model.kata_ran_tests(
      id: id, files: files, stdout: stdout, stderr: stderr,
      status: '0', summary: red_summary, laptop_id: default_laptop_id
    )

    assert_tag_commit_message(id, 1, '1 ran tests')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ndx008', %w(
  | the HTTP boundary (post_json) strips index only for event-writes, not for the
  | fork methods: a kata_fork POST keeps its index (the fork's event position), so
  | forking at a given index still works through the dispatch.
  ) do
    id = kata_create(custom_manifest)

    assert_json_post_200('kata_fork', { id: id, index: 0 }.to_json) do |response|
      forked_id = response['kata_fork']
      assert kata_exists?(forked_id), forked_id
    end
  end

end
