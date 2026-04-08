require_relative 'test_base'

class KataConcurrentSavesTest < TestBase

  version_test 2, 'DccG01', %w(
  | concurrent kata_option_set calls on the same kata
  | do not raise 'Diverging branches cannot be fast-forwarded'
  ) do
    in_kata do |id|
      errors = []
      mutex = Mutex.new
      threads = [
        ['theme',        'dark'],
        ['colour',       'off'],
        ['predict',      'on'],
        ['revert_red',   'on'],
        ['revert_amber', 'on'],
        ['revert_green', 'on'],
      ].map do |(name, value)|
        Thread.new do
          saver.kata_option_set(id, name, value)
        rescue => error
          # :nocov:
          mutex.synchronize { errors << error.message }
          # :nocov:
        end
      end
      threads.each(&:join)
      assert_empty errors
    end
  end

  version_test 2, 'DccG02', %w(
  | kata_ran_tests does not raise 'Out of order event' for its second
  | git_ff_merge_worktree call when a concurrent kata_ran_tests intervenes.
  |
  | kata_ran_tests calls git_ff_merge_worktree twice:
  |   1st call: via file_edit - commits the large file edit (slow)
  |   2nd call: commits the test run at index=2
  |
  | Each b_thread calls kata_ran_tests at index=2 with a unique file edit.
  | Each b_thread's file_edit detects its unique edit and blocks on the
  | per-call mutex while thread_a holds it for its slow 1st commit.
  | When thread_a releases, one b_thread immediately acquires, commits at
  | index=2, and thread_a's 2nd commit raises 'Out of order event'.
  | 100 b_threads ensure at least one is queued on the mutex when thread_a
  | releases, making the race reliable.
  |
  | After applying post_json_with_mutex, thread_a holds the mutex for its
  | entire HTTP request (both commits are atomic), so no b_thread can
  | intervene and thread_a succeeds.
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      stdout  = { 'content' => '', 'truncated' => false }
      stderr  = { 'content' => '', 'truncated' => false }
      status  = 0
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      # thread_a uses a large edit so its first git_ff_merge_worktree is slow,
      # giving b_threads time to queue up on the mutex.
      large_files = files.merge('tennis.py' => { 'content' => 'x' * 100_000 })

      # Each b_thread gets a unique edit so its file_edit always detects a
      # change and calls git_ff_merge_worktree, queuing on the mutex.
      b_files = 100.times.map do |i|
        files.merge('tennis.py' => { 'content' => 'x' * 100_000 + i.to_s })
      end

      errors = []
      errors_mutex = Mutex.new

      thread_a = Thread.new do
        saver.kata_ran_tests(id, 1, large_files, stdout, stderr, status, summary)
      rescue => error
        # :nocov:
        errors_mutex.synchronize { errors << error.message }
        # :nocov:
      end

      b_threads = b_files.map do |bf|
        Thread.new do
          saver.kata_ran_tests(id, 2, bf, stdout, stderr, status, summary)
        rescue
          # Each b_thread's own success or failure is irrelevant;
          # only thread_a's outcome matters.
        end
      end

      ([thread_a] + b_threads).each(&:join)
      assert_empty errors
    end
  end

end
