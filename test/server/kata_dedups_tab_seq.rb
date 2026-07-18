require_relative 'test_base'

class KataDedupsTabSeqTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ts5D01', %w(
  | a redelivered kata_ran_tests carrying the same (laptop_id, tab_seq) as an
  | already-committed event is deduplicated at the saver: the redelivery
  | appends no second event. tab_seq counts EVERY event the tab fires, so by
  | the first test run the tab is already several edits in - the run is not
  | tab_seq 1. This is the A8 idempotency guard that later lets the spooler
  | redeliver a queued write without double-committing it.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    fn = files.keys.first

    # A real tab session: the learner edits the starter file a few times, each
    # edit its own event, before running the tests. tab_seq tracks that order.
    files[fn]['content'] += "\n# first attempt"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 1)
    files[fn]['content'] += "\n# second attempt"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 2)
    files[fn]['content'] += "\n# third attempt"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 3)

    run = {
      id: id, files: files,
      stdout: { 'content' => 'some output', 'truncated' => false },
      stderr: { 'content' => '',            'truncated' => false },
      status: '0', summary: red_summary,
      laptop_id: laptop_id, tab_seq: 4
    }
    model.kata_ran_tests(**run)
    committed = kata_events(id).size

    model.kata_ran_tests(**run)
    assert_equal committed, kata_events(id).size, 'redelivery of tab_seq 4 is a no-op'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ts5D02', %w(
  | the dedup guard also covers the file-event writes. A file_create is a
  | fire-and-forget ITE the browser re-fires on loss (ADR section 6); a re-fire
  | carrying the same (laptop_id, tab_seq) as the already-committed create is a
  | no-op, so no second event is appended.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    fn = files.keys.first

    files[fn]['content'] += "\n# a note"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 1)
    model.kata_ran_tests(
      id: id, files: files,
      stdout: { 'content' => 'red', 'truncated' => false },
      stderr: { 'content' => '',    'truncated' => false },
      status: '0', summary: red_summary,
      laptop_id: laptop_id, tab_seq: 2
    )
    files[fn]['content'] += "\n# more work"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 3)

    create = { id: id, files: files, filename: 'extra_test.rb', laptop_id: laptop_id, tab_seq: 4 }
    model.kata_file_create(**create)
    committed = kata_events(id).size

    model.kata_file_create(**create)
    assert_equal committed, kata_events(id).size, 're-fire of tab_seq 4 is a no-op'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ts5D03', %w(
  | redelivering a write that expanded into two events - an implicit file_edit
  | and a real file_create sharing one tab_seq - is a full no-op: neither event
  | is duplicated. The colour-keyed guard dedups each against its committed twin.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    fn = files.keys.first

    files[fn]['content'] += "\n# saved edit"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 1)

    files[fn]['content'] += "\n# unsaved edit carried by the create"
    create = { id: id, files: files, filename: 'wibble.txt', laptop_id: laptop_id, tab_seq: 2 }
    model.kata_file_create(**create)
    committed = kata_events(id).size

    model.kata_file_create(**create)
    assert_equal committed, kata_events(id).size, 're-fire of the whole write is a no-op'
  end

end
