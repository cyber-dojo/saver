require_relative 'test_base'

class KataLaptopIdTest < TestBase

  version_test 2, 'La7C01', %w(
  | a kata_file_create passing a well-formed laptop_id stores it on the
  | committed event, read back through the client
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      kata_file_create(id, files, 'wibble.txt', laptop_id)
      assert_equal laptop_id, kata_event(id, 1)['laptop_id']
    end
  end

  version_test 2, 'La7C02', %w(
  | a kata_file_create whose laptop_id is nil (a browser with no laptop_id
  | cookie) commits, and the event carries no laptop_id key
  ) do
    in_kata do |id|
      files = kata_event(id, 0)['files']
      kata_file_create(id, files, 'wibble.txt', nil)
      refute kata_event(id, 1).key?('laptop_id'), kata_event(id, 1).to_json
    end
  end

end
