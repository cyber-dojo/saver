require_relative 'test_base'

class KataDedupsTabSeqTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ts5D01', %w(
  | a redelivered kata_ran_tests carrying the same (laptop_id, tab_seq) as an
  | already-committed event is deduplicated at the saver: no second event is
  | appended. This is the A8 idempotency guard - the key that later lets the
  | spooler redeliver a queued write without double-committing it.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'o', 'truncated' => false }
    stderr = { 'content' => 'e', 'truncated' => false }
    args = {
      id: id, files: files,
      stdout: stdout, stderr: stderr, status: '0',
      summary: red_summary, laptop_id: LAPTOP_A, tab_seq: 1
    }

    model.kata_ran_tests(**args)
    assert_equal 2, kata_events(id).size, 'first write appends event 1'

    model.kata_ran_tests(**args)
    assert_equal 2, kata_events(id).size, 'redelivery is a no-op'
  end

  # Realistic laptop_id: SecureRandom.hex(32), as minted by the web before-hook.
  LAPTOP_A = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'

end
