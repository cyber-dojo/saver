require_relative 'test_base'

class KatasEventsTest < TestBase

  version_test 0, 'LS52R6', %w( 
  | v0 example 
  ) do
    actual = katas_events([V0_KATA_ID, V0_KATA_ID], [2, 3])
    expected = {
      V0_KATA_ID => {
        '2' => kata_event_k5ZTk0_2,
        '3' => kata_event_k5ZTk0_3,
      }
    }
    assert_equal expected, actual
  end

  version_test 1, 'LS51P3', %w( 
  | v1 example 
  ) do
    actual = katas_events([V1_KATA_ID, V1_KATA_ID], [1, 2])
    expected = {
      V1_KATA_ID => {
        '1' => kata_event_rUqcey_1,
        '2' => kata_event_rUqcey_2,
      }
    }
    assert_equal expected, actual
  end

  version_test 2, 'LS51P4', %w( 
  | v2 example 
  ) do
    now = [2018, 11, 30, 9, 34, 56, 6_453]
    externals.instance_exec do
      @time = TimeStub.new(now, now, now, now, now, now, now)
    end
    files = nil
    stdout = { 'content' => 'so', 'truncated' => false }
    stderr = { 'content' => 'se', 'truncated' => true }
    red_summary = { 'colour' => 'red' }
    in_group do |gid|
      ids = []
      in_kata(gid) do |id|
        files = kata_event(id, 0)['files']
        ids << id
        kata_ran_tests(id, 1, files, stdout, stderr, "0", red_summary)
      end
      in_kata(gid) do |id|
        files = kata_event(id, 0)['files']
        ids << id
        kata_ran_tests(id, 1, files, stdout, stderr,   '0', red_summary)
        kata_ran_tests(id, 2, files, stdout, stderr,   '0', red_summary)
        kata_ran_tests(id, 3, files, stdout, stderr, '137', red_summary)
      end
      actual = katas_events([ids[0], ids[1]], [1, 3])
      expected = {
        ids[0] => {
          '1' => {
            'index' => 1,
            'files' => files,
            'colour' => 'red',
            'time' => now,
            'stdout' => stdout,
            'stderr' => stderr,
            'status' => '0',
            'diff_added_count' => 0, 
            'diff_deleted_count' => 0
          }
        },
        ids[1] => {
          '3' => {
            'index' => 3,
            'files' => files,
            'colour' => 'red',
            'time' => now,
            'stdout' => stdout,
            'stderr' => stderr,
            'status' => '137',
            'diff_added_count' => 0, 
            'diff_deleted_count' => 0
          }
        }
      }
      assert_equal expected, actual
    end
  end
end
