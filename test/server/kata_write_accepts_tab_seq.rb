require_relative 'test_base'

class KataWriteAcceptsTabSeqTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Aq5F01', %w(
  | a write POST carrying a tab_seq field is accepted (HTTP 200): the write
  | boundary (post_json) passes tab_seq through to the method, which declares it
  | as an optional keyword, so web can start stamping it before the spooler
  | exists. Shown across two write shapes - a file_edit ITE then a ran_tests -
  | with a monotonic tab_seq, as a real tab sends.
  ) do
    laptop_id = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'
    id = kata_create(custom_manifest)
    files = kata_event(id, 0)['files']
    fn = files.keys.first

    files[fn]['content'] += "\n# editing"
    edit_body = { id: id, files: files, laptop_id: laptop_id, tab_seq: 1 }.to_json
    assert_json_post_200('kata_file_edit', edit_body) do |response|
      assert_equal 2, response['kata_file_edit'], 'next_index after the edit'
    end

    run_body = {
      id: id, files: files,
      stdout: { 'content' => 'some-stdout', 'truncated' => false },
      stderr: { 'content' => 'some-stderr', 'truncated' => false },
      status: '0', summary: red_summary,
      laptop_id: laptop_id, tab_seq: 2
    }.to_json
    assert_json_post_200('kata_ran_tests', run_body) do |response|
      assert_equal 3, response['kata_ran_tests']['next_index'], 'next_index after the run'
    end
  end

end
