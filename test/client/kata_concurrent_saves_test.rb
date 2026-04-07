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

end
