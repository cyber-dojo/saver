require_relative 'test_base'

class KataWriteAcceptsLaptopIdTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ac1B7a', %w(
  | a kata_file_create POST carrying an extra laptop_id field is accepted
  | (HTTP 200), not rejected by the strict-keyword dispatch as an unknown
  | keyword. The saver tolerates the field, and does nothing with it, so web
  | can start sending it before the saver stores it.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    body = {
      id: id,
      index: 1,
      files: files,
      filename: 'wibble.txt',
      laptop_id: 'a1b2c3d4e5f6'
    }.to_json

    assert_json_post_200('kata_file_create', body) do
      assert_equal 2, kata_events(id).size
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ac1B7b', %w(
  | a kata_ran_tests POST carrying an extra laptop_id field is accepted
  | (HTTP 200), covering the stdout/stderr/status/summary write shape as
  | well as the filename write shape.
  ) do
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    stdout = { 'content' => 'some-stdout', 'truncated' => false }
    stderr = { 'content' => 'some-stderr', 'truncated' => false }
    status = '0'
    body = {
      id: id,
      index: 1,
      files: files,
      stdout: stdout,
      stderr: stderr,
      status: status,
      summary: red_summary,
      laptop_id: 'a1b2c3d4e5f6'
    }.to_json

    assert_json_post_200('kata_ran_tests', body) do
      assert_equal 2, kata_events(id).size
    end
  end

end
