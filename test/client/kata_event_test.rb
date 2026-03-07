require_relative 'test_base'

class KataEventTest < TestBase

  version_test 0, 'Lw22R6', %w( v0 example ) do
    actual = kata_event(V0_KATA_ID, 2)
    expected = kata_event_k5ZTk0_2
    assert_equal expected, actual
  end

  version_test 0, 'Lw22R7', %w( v0 example next event ) do
    actual = kata_event(V0_KATA_ID, 3)
    expected = kata_event_k5ZTk0_3
    assert_equal expected, actual
  end

  version_test 1, 'Lw21P3', %w( v1 example ) do
    actual = kata_event(V1_KATA_ID, 1)
    expected = kata_event_rUqcey_1
    assert_equal expected, actual
  end

  version_test 1, 'Lw21P4', %w( v1 example next event) do
    actual = kata_event(V1_KATA_ID, 2)
    expected = kata_event_rUqcey_2
    assert_equal expected, actual
  end

  version_test 2, 'Lw21P5', %w( v2 bad +ve index raises ) do
    in_kata do |id|
      index = 0
      event = kata_event(id, index) # ok
      files = event['files']

      index = 1
      next_index = kata_file_rename(id, index, files, 'readme.txt', 'readme.md')
      assert_equal 2, next_index

      kata_event(id, 1) # ok

      bad_index = 2
      error = assert_raises(HttpJsonHash::ServiceError) do
        kata_event(id, bad_index)
      end
      expected = "Invalid +ve index #{bad_index} [2 events]"
      assert_equal expected, error.message
    end
  end

  version_test 2, 'Lw21P6', %w( v2 bad -ve index raises ) do
    in_kata do |id|
      index = -1
      event = kata_event(id, index) # ok
      files = event['files']
      index = 1
      next_index = kata_file_rename(id, index=1, files, 'readme.txt', 'readme.md')
      assert_equal 2, next_index

      kata_event(id, -2) # ok

      bad_index = -3
      error = assert_raises(HttpJsonHash::ServiceError) do
        kata_event(id, bad_index)
      end
      expected = "Invalid -ve index #{bad_index} (=> -1) [2 events]"
      assert_equal expected, error.message
    end
  end
end
