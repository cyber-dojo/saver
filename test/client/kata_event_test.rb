require_relative 'test_base'

class KataEventTest < TestBase

  def self.id58_prefix
    'Lw2'
  end

  version_test 0, '2R6', %w( v0 example ) do
    actual = kata_event(V0_KATA_ID, 2)
    expected = kata_event_k5ZTk0_2
    expected['major_index'] = 2
    expected['minor_index'] = 0
    assert_equal expected, actual
  end

  version_test 0, '2R7', %w( v0 example next event ) do
    actual = kata_event(V0_KATA_ID, 3)
    expected = kata_event_k5ZTk0_3
    expected['major_index'] = 3
    expected['minor_index'] = 0
    assert_equal expected, actual
  end

  version_test 1, '1P3', %w( v1 example ) do
    actual = kata_event(V1_KATA_ID, 1)
    expected = kata_event_rUqcey_1
    expected['major_index'] = 1
    expected['minor_index'] = 0
    assert_equal expected, actual
  end

  version_test 1, '1P4', %w( v1 example next event) do
    actual = kata_event(V1_KATA_ID, 2)
    expected = kata_event_rUqcey_2
    expected['major_index'] = 2
    expected['minor_index'] = 0
    assert_equal expected, actual
  end

  version_test 2, '1P5', %w( v2 bad +ve index raises ) do
    in_kata do |id|
      index = 0
      event = kata_event(id, index)

      files = event['files']
      index = 1
      kata_file_create(id, index, files, 'wibble.txt')
      kata_event(id, index)

      bad_index = 2
      error = assert_raises(HttpJsonHash::ServiceError) do
        kata_event(id, bad_index)
      end
      assert_equal "Invalid index #{bad_index}", error.message
    end
  end

  version_test 2, '1P6', %w( v2 bad -ve index raises ) do
    in_kata do |id|
      index = -1
      event = kata_event(id, index)

      files = event['files']
      index = 1
      kata_file_create(id, index, files, 'wibble.txt')
      index = -2
      kata_event(id, index)

      bad_index = -3
      error = assert_raises(HttpJsonHash::ServiceError) do
        kata_event(id, bad_index)
      end
      assert_equal "Invalid index #{bad_index}", error.message
    end
  end
end
