require_relative 'test_base'
require 'base64'
require 'json'
require 'tmpdir'

class KataDownloadTest < TestBase

  version_test 2, 'Dn4Kp1', %w(
  | kata_download returns a base64 .tgz which the real tar extracts.
  | Its root dir is named after the tgz, and holds a git repo carrying the
  | kata's committed files, events.json and README.md.
  | The repo has no origin remote pointing back at saver's disk.
  ) do
    in_kata do |id|
      expected_cyber_dojo_sh = kata_event(id, 0)['files']['cyber-dojo.sh']['content']
      tgz_filename, encoded64 = *kata_download(id)
      assert tgz_filename.end_with?('.tgz'), tgz_filename

      Dir.mktmpdir do |tmp_dir|
        File.binwrite("#{tmp_dir}/#{tgz_filename}", Base64.decode64(encoded64))
        # The real tar, not saver's own tgz reader: the download has to open
        # with the tar a user has. Its verbose output is captured so a passing
        # test stays silent.
        output = `cd #{tmp_dir} && tar -xvf #{tgz_filename} 2>&1`
        assert_equal 0, $?.exitstatus, output

        dir_path = "#{tmp_dir}/#{tgz_filename.chomp('.tgz')}"
        assert File.directory?(dir_path), dir_path
        assert File.directory?("#{dir_path}/.git"), dir_path

        assert_equal expected_cyber_dojo_sh, File.read("#{dir_path}/files/cyber-dojo.sh")

        events = JSON.parse(File.read("#{dir_path}/events.json"))
        assert_equal 1, events.size, events.inspect

        readme = File.read("#{dir_path}/README.md")
        url = "https://cyber-dojo.org/kata/edit/#{id}"
        link = "# This a copy of [your cyber-dojo exercise](#{url}):"
        assert readme.include?(link), readme

        # No url of any kind is recorded, so nothing in the repo points back at
        # saver's disk. Checked by reading .git/config because the client image
        # has no git; the server test makes the same point with `git remote -v`.
        config = File.read("#{dir_path}/.git/config")
        refute config.include?('url'), config
      end
    end
  end

end
