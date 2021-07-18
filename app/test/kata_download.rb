require_relative 'test_base'
require_source 'model/kata_v2'
require 'tmpdir'

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
      year, month, day = 2021, 7, 11
      externals.instance_exec { @time = TimeStub.new([year, month, day]) }
      tgz_filename, encoded64 = *model.kata_download(id:id)
      assert tgz_filename.end_with?('.tgz')
      Dir.mktmpdir do |tmp_dir|
        File.write("#{tmp_dir}/#{tgz_filename}", Base64.decode64(encoded64))
        untar_command = "tar -xvf #{tgz_filename}"
        shell.assert_cd_exec(tmp_dir, untar_command)
        dir_name = "cyber-dojo-#{year}-#{month}-#{day}-#{id}"
        shell.assert_cd_exec(tmp_dir, "[ -d #{dir_name} ]")
        dir_path = "#{tmp_dir}/#{dir_name}"
        shell.assert_cd_exec(dir_path, "[ -d .git ]")
        tags = shell.assert_cd_exec(dir_path, "git tag")
        assert_equal 3, tags.split("\n").count
        assert_last_commit_message(dir_path, "2 ran tests, no prediction, got red")
        cyber_dojo_sh = shell.assert_cd_exec(dir_path, "cat files/cyber-dojo.sh")
        assert_equal "pytest *_test.rb", cyber_dojo_sh
        readme_md = shell.assert_cd_exec(dir_path, "cat README.md")
        url = "https://cyber-dojo.org/kata/edit/#{id}"
        link = "# This a copy of [your cyber-dojo exercise](#{url}):"
        assert readme_md.include?(link)
      end
    end
  end

  def assert_last_commit_message(dir_path, expected)
    latest_commits_messages = shell.assert_cd_exec(dir_path, "git log --abbrev-commit --pretty=oneline")
    last_commits_message = latest_commits_messages.lines[0]
    diagnostic = "\nexpected:#{expected}\n  actual:#{last_commits_message}"
    assert last_commits_message.include?(expected), diagnostic
  end

  version_test 2, '75t', %w(
  |downloaded README.md file for custom exercise
  ) do
    manifest = custom_manifest
    refute manifest.keys.include?('exercise')
    manifest['display_name'] = 'C++ Countdown, Round 3'
    readme = Kata_v2.new(externals).send(:readme, manifest)
    assert readme.include?('- Custom exercise: `C++ Countdown, Round 3`'), readme
    refute readme.include?('- Language'), readme
  end

  version_test 2, '75u', %w(
  |downloaded README.md file for non-custom exercise
  ) do
    manifest = custom_manifest
    manifest['exercise'] = "Print Diamond"
    manifest['display_name'] = "Bash, bats"
    readme = Kata_v2.new(externals).send(:readme, manifest)
    assert readme.include?("- Exercise: `Print Diamond`"), readme
    assert readme.include?("- Language & test-framework: `Bash, bats`"), readme
  end

end
