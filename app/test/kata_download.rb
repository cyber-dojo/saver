require_relative 'test_base'

class KataDownloadTest < TestBase

  def self.id58_prefix
    'kL3'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, '75s', %w(
  |kata_exists? is false,
  |for a well-formed id that does not exist
  ) do
    files = { "cyber-dojo.sh" => { "content" => "pytest *_test.rb" }}
    stdout = { "content" => "so", "truncated" => false }
    stderr = { "content" => "se", "truncated" => true }
    summary = { "colour" => "red" }
    
    in_kata do |id|
      kata_ran_tests(id, 1, files, stdout, stderr,   "0", summary)
      kata_ran_tests(id, 2, files, stdout, stderr,   "1", summary)
      _tmp_dir, _true_name, _user_name = model.kata_download(id:id)
      #p(tmp_dir)
      #p(true_name)
      #p(user_name)
      # TODO: assert on untarred files
    end
  end

end
