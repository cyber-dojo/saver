require_relative 'test_base'

class KataStoresTabSeqTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Sq5E01', %w(
  | each write stores its tab_seq on the committed event (the tab's own
  | monotonic counter), so a later redelivery of the same (laptop_id, tab_seq)
  | can be recognised and deduped. tab_seq counts every event the tab fires,
  | so the session's first edit is tab_seq 1 and the first test run is later.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    fn = files.keys.first

    files[fn]['content'] += "\n# first attempt"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 1)
    files[fn]['content'] += "\n# second attempt"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 2)
    model.kata_ran_tests(
      id: id, files: files,
      stdout: { 'content' => 'some output', 'truncated' => false },
      stderr: { 'content' => '',            'truncated' => false },
      status: '0', summary: red_summary,
      laptop_id: laptop_id, tab_seq: 3
    )

    assert_equal 1, kata_event(id, 1)['tab_seq'], 'file_edit'
    assert_equal 2, kata_event(id, 2)['tab_seq'], 'file_edit'
    assert_equal 3, kata_event(id, 3)['tab_seq'], 'ran_tests'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Sq5E02', %w(
  | a write with no tab_seq (an interim browser from before web stamps one -
  | A8 ships before A9) stores NO tab_seq key on the committed event, mirroring
  | laptop_id's optional-first discipline. Such a write is simply not deduped by
  | key; its other fields are unchanged.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    model.kata_ran_tests(
      id: id, files: files,
      stdout: { 'content' => 'some output', 'truncated' => false },
      stderr: { 'content' => '',            'truncated' => false },
      status: '0', summary: red_summary,
      laptop_id: laptop_id
    )

    event = kata_event(id, 1)
    refute event.key?('tab_seq'), event.to_json
    assert_equal laptop_id, event['laptop_id']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Sq5E03', %w(
  | a write that also commits an implicit file_edit stamps BOTH events - the
  | underneath edit and the real event - with the SAME tab_seq (web assigned one
  | tab_seq to the action; the saver expands it into two commits). The real event
  | must still be committed, NOT dropped as a dedup of its own sibling: the guard
  | matches on colour too, and the two events differ in colour.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    fn = files.keys.first

    files[fn]['content'] += "\n# saved edit one"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 1)
    files[fn]['content'] += "\n# saved edit two"
    model.kata_file_edit(id: id, files: files, laptop_id: laptop_id, tab_seq: 2)

    # The learner types more (an unsaved edit) and then creates a file. The
    # create is one browser action (tab_seq 3); the saver catches the unsaved
    # edit underneath it, so tab_seq 3 yields two events.
    files[fn]['content'] += "\n# unsaved edit carried by the create"
    model.kata_file_create(id: id, files: files, filename: 'wibble.txt', laptop_id: laptop_id, tab_seq: 3)

    assert_equal 5, kata_events(id).size, 'created, edit1, edit2, implicit edit, file_create'
    assert_equal 'file_edit',   kata_event(id, 3)['colour']
    assert_equal 'file_create', kata_event(id, 4)['colour']
    assert_equal 3, kata_event(id, 3)['tab_seq'], 'underneath edit carries the action tab_seq'
    assert_equal 3, kata_event(id, 4)['tab_seq'], 'real event carries the action tab_seq'
  end

end
