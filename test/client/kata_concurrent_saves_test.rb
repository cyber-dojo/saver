require_relative 'test_base'

class KataConcurrentSavesTest < TestBase

  version_test 2, 'DccG02', %w(
  | N concurrent kata_ran_tests calls to the same kata-id all use index=1.
  | Exactly one succeeds (whichever acquires the non-blocking flock first).
  | The remaining N-1 all get 'Out of order event': either immediately from
  | the flock, or from the index check (1 != last_index+1 once index=1 is
  | taken). Even sequential execution cannot produce more than one success
  | since all threads hardcode index=1.
  ) do
    n = 10
    in_kata do |id|
      files   = kata_event(id, 0)['files']
      stdout  = { 'content' => '', 'truncated' => false }
      stderr  = { 'content' => '', 'truncated' => false }
      status  = 0
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      errors = []
      mu = Mutex.new

      n.times.map do
        Thread.new do
          saver.kata_ran_tests(id, 1, files, stdout, stderr, status, summary)
        rescue => error
          mu.synchronize { errors << error.message }
        end
      end.each(&:join)

      assert errors.all? { |e| e.include?('Out of order event') }
      assert_equal n - 1, errors.length
    end
  end

end
