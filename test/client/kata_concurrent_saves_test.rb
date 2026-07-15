require_relative 'test_base'
require 'securerandom'

class KataConcurrentSavesTest < TestBase

  version_test 2, 'DccG02', %w(
  | N concurrent kata_ran_tests calls to the same kata-id, each from a DIFFERENT
  | laptop_id, all use index=1 (genuine mobbing: N laptops racing the same
  | next-event slot). Exactly one succeeds. The remaining N-1 all get
  | 'Out of order event': either from losing the update-ref compare-and-swap
  | (concurrent case) or from the mobbing check rejecting a behind index whose
  | intervening event was written by a different laptop (sequential case).
  | Distinct laptop_ids are essential: with a shared laptop_id a behind write is
  | accepted as self-lag, so more than one call could succeed.
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
          saver.kata_ran_tests(id, 1, files, stdout, stderr, status, summary, laptop_ids[i])
        rescue => error
          mu.synchronize { errors << error.message }
        end
      end.each(&:join)

      assert errors.all? { |e| e.include?('Out of order event') }
      assert_equal n - 1, errors.length
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
          saver.kata_ran_tests(id, 1, files, stdout, stderr, status, summary, laptop_id)
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
