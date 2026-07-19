require_relative 'test_base'

class KataTabSeqTest < TestBase

  version_test 2, 'Tq9S01', %w(
  | each write stores its tab_seq on the committed event (the tab's own
  | monotonic counter), read back through the client
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      fn = files.keys.first

      files[fn]['content'] += "\n# first attempt"
      saver.kata_file_edit(id, files, laptop_id, 1)
      files[fn]['content'] += "\n# second attempt"
      saver.kata_file_edit(id, files, laptop_id, 2)

      assert_equal 1, kata_event(id, 1)['tab_seq'], 'first edit'
      assert_equal 2, kata_event(id, 2)['tab_seq'], 'second edit'
    end
  end

  version_test 2, 'Tq9S02', %w(
  | a redelivered write carrying an already-committed (laptop_id, tab_seq) is a
  | no-op: it is not committed a second time, so only the original event exists
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      stdout = { 'content' => 'o', 'truncated' => false }
      stderr = { 'content' => 'e', 'truncated' => false }
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      saver.kata_ran_tests(id, files, stdout, stderr, 0, summary, laptop_id, 1)
      saver.kata_ran_tests(id, files, stdout, stderr, 0, summary, laptop_id, 1)

      events = kata_events(id)
      assert_equal 2, events.size, events.to_s
      assert_equal 1, events.last['tab_seq']
    end
  end

  version_test 2, 'Tq9S03', %w(
  | two writes carrying distinct tab_seq are two genuine writes, so both commit
  | (the dedup key differs), at contiguous indices
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      stdout = { 'content' => 'o', 'truncated' => false }
      stderr = { 'content' => 'e', 'truncated' => false }
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      saver.kata_ran_tests(id, files, stdout, stderr, 0, summary, laptop_id, 1)
      saver.kata_ran_tests(id, files, stdout, stderr, 0, summary, laptop_id, 2)

      events = kata_events(id)
      assert_equal 3, events.size, events.to_s
      assert_equal [1, 2], events.drop(1).map { |event| event['tab_seq'] }
    end
  end

end
