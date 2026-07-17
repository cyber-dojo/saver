require_relative 'test_base'
require 'securerandom'

class KataConcurrentSavesTest < TestBase

  version_test 2, 'DccG02', %w(
  | N concurrent kata_ran_tests calls to the same kata-id, each from a DIFFERENT
  | laptop_id, all at index=1 - N laptops racing the same next-event slot. The
  | saver appends every write (a CAS-loss loser retries onto the new head) and does
  | not reject a behind index, so laptop_id does not gate placement: ALL N commit,
  | at contiguous indices in some order, none rejected. The browsers' read-side
  | polls, not the saver, flag the mobbing. (DccG03 is the shared-laptop_id mirror
  | of this.)
  ) do
    n = 10
    in_kata do |id|
      files   = kata_event(id, 0)['files']
      stdout  = { 'content' => '', 'truncated' => false }
      stderr  = { 'content' => '', 'truncated' => false }
      status  = 0
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      laptop_ids = n.times.map { SecureRandom.hex(32) }
      errors = []
      mu = Mutex.new

      n.times.map do |i|
        Thread.new do
          saver.kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_ids[i])
        rescue => error
          # Every racing write is appended, so this path never runs when green:
          # no write fails.
          # :nocov:
          mu.synchronize { errors << error.message }
          # :nocov:
        end
      end.each(&:join)

      assert_equal [], errors, errors.to_s
      events = kata_events(id)
      assert_equal n + 1, events.size, events.to_s
      assert_equal (0..n).to_a, events.map { |e| e['index'] }
    end
  end

  version_test 2, 'DccG03', %w(
  | N concurrent kata_ran_tests to the same kata-id, all from the SAME laptop_id
  | and all at index=1 - a single browser racing its own writes (eg [test] firing
  | while an inter-test event is still in flight). None is genuine mobbing: every
  | racing event is this laptop's own, so ALL N must commit (at contiguous indices,
  | in some order), none rejected. A CAS-loss loser that is this same laptop's own
  | write must retry (rebuild on the new head and re-append) rather than raise
  | 'Out of order event'.
  ) do
    n = 5
    in_kata do |id|
      files   = kata_event(id, 0)['files']
      stdout  = { 'content' => '', 'truncated' => false }
      stderr  = { 'content' => '', 'truncated' => false }
      status  = 0
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      laptop_id = SecureRandom.hex(32)
      errors = []
      mu = Mutex.new

      n.times.map do
        Thread.new do
          saver.kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id)
        rescue => error
          # This error-collection path only runs if a write fails. With the fix
          # every same-laptop write succeeds, so it is never reached when green.
          # :nocov:
          mu.synchronize { errors << error.message }
          # :nocov:
        end
      end.each(&:join)

      assert_equal [], errors, errors.to_s
      events = kata_events(id)
      assert_equal n + 1, events.size, events.to_s
      assert_equal (0..n).to_a, events.map { |e| e['index'] }
    end
  end

end
