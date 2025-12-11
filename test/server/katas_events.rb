require_relative 'test_base'

class KatasEventsTest < TestBase
  def self.id58_prefix
    'LS5'
  end

  version_test 0, '2R6', %w( v0 example ) do
    actual = katas_events([V0_KATA_ID,V0_KATA_ID], [2,3])
    expected = {
      V0_KATA_ID => {
        "2" => kata_event_k5ZTk0_2,
        "3" => kata_event_k5ZTk0_3,
      }
    }
    assert_equal expected, actual
  end

  version_test 1, '1P3', %w( v1 example ) do
    actual = katas_events([V1_KATA_ID,V1_KATA_ID], [1,2])
    expected = {
      V1_KATA_ID => {
        '1' => kata_event_rUqcey_1,
        '2' => kata_event_rUqcey_2,
      }
    }
    assert_equal expected, actual
  end

  version_test 2, '1P4', %w( v2 example ) do
    now = [2018,11,30, 9,34,56,6453]
    externals.instance_exec {
      @time = TimeStub.new(now, now, now, now, now, now, now)
    }
    files = { 'cyber-dojo.sh' => { 'content' => 'pytest *_test.rb' }}
    stdout = { 'content' => 'so', 'truncated' => false }
    stderr = { 'content' => 'se', 'truncated' => true }
    summary = { 'colour' => 'red' }
    in_group do |gid|
      ids = []
      in_kata(gid) do |id|
        ids << id
        kata_ran_tests(id, 1, files, stdout, stderr, "0", summary)
      end
      in_kata(gid) do |id|
        ids << id
        kata_ran_tests(id, 1, files, stdout, stderr,   '0', summary)
        kata_ran_tests(id, 2, files, stdout, stderr,   '0', summary)
        kata_ran_tests(id, 3, files, stdout, stderr, '137', summary)
      end
      actual = katas_events([ids[0],ids[1]], [1,3])
      expected = {
        ids[0] => {
          '1' => {
            'index' => 1,
            'files' => files,
            'colour' => 'red',
            'time' => now,
            'stdout' => stdout,
            'stderr' => stderr,
            'status' => '0'
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
            'status' => '137'
          }
        }
      }
      assert_equal expected, actual
    end
  end
end
