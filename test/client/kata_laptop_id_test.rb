require_relative 'test_base'

class KataLaptopIdTest < TestBase

  version_test 2, 'La7C01', %w(
  | a kata_file_create passing a well-formed laptop_id stores it on the
  | committed event, read back through the client
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      saver.kata_file_create(id, 1, files, 'wibble.txt', laptop_id)
      assert_equal laptop_id, kata_event(id, 1)['laptop_id']
    end
  end

  version_test 2, 'La7C02', %w(
  | a kata_file_create with no laptop_id (the transitional default) still
  | succeeds and stores no laptop_id key on the event
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      next_index = saver.kata_file_create(id, 1, files, 'wibble.txt')
      assert_equal 2, next_index
      refute kata_event(id, 1).key?('laptop_id'), kata_event(id, 1).to_json
    end
  end

  version_test 2, 'La7C03', %w(
  | a stale-index write from a different laptop_id is rejected by the saver as
  | out-of-order (genuine mobbing), surfaced through the client as a ServiceError.
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      stdout = { 'content' => 'o', 'truncated' => false }
      stderr = { 'content' => 'e', 'truncated' => false }
      summary = { 'colour' => 'red', 'predicted' => 'none' }

      saver.kata_ran_tests(id, 1, files, stdout, stderr, 0, summary, laptop_id)

      error = assert_raises(HttpJsonHash::ServiceError) {
        saver.kata_ran_tests(id, 1, files, stdout, stderr, 0, summary, another_laptop_id)
      }
      assert_equal "Out of order event for #{id}", error.message
    end
  end

end
