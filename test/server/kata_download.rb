require_relative 'test_base'
require_source 'model/kata_v2'
require 'base64'
require 'tmpdir'

class KataDownloadTest < TestBase

  version_test 2, 'kL375s', %w(
  | kata_exists? is false,
  | for a well-formed id that does not exist
  ) do
    stdout = { 'content' => 'so', 'truncated' => false }
    stderr = { 'content' => 'se', 'truncated' => true }
    summary = { 'colour' => 'red' }

    in_kata do |id|
      files = kata_event(id, 0)['files']
      expected_cyber_dojo_sh = files['cyber-dojo.sh']['content']
      kata_ran_tests(id, files, stdout, stderr,   '0', summary)
      kata_ran_tests(id, files, stdout, stderr,   '1', summary)
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
        shell.assert_cd_exec(dir_path, '[ -d .git ]')
        tags = shell.assert_cd_exec(dir_path, 'git tag')
        # tags are exactly 0,1,2 (names, not just count)
        assert_equal %w(0 1 2), tags.split("\n").sort
        # full history: one commit per event, right messages, newest first
        subjects = shell.assert_cd_exec(dir_path, 'git log --pretty=%s').split("\n")
        assert_equal [
          '2 ran tests, no prediction, got red',
          '1 ran tests, no prediction, got red',
          '0 kata creation',
        ], subjects
        # each tag points at the commit for its index (commit<->tag correspondence)
        %w(0 1 2).each do |i|
          subject = shell.assert_cd_exec(dir_path, "git log -1 --pretty=%s #{i}")
          assert subject.start_with?("#{i} "), "tag #{i} -> #{subject}"
        end
        # working tree is checked out clean at HEAD (nothing missing or modified)
        status = shell.assert_cd_exec(dir_path, 'git status --porcelain')
        assert_equal '', status, status
        actual_cyber_dojo_sh = shell.assert_cd_exec(dir_path, 'cat files/cyber-dojo.sh')
        #assert_equal 'pytest *_test.rb', cyber_dojo_sh
        assert_equal expected_cyber_dojo_sh, actual_cyber_dojo_sh
        readme_md = shell.assert_cd_exec(dir_path, 'cat README.md')
        url = "https://cyber-dojo.org/kata/edit/#{id}"
        link = "# This a copy of [your cyber-dojo exercise](#{url}):"
        assert readme_md.include?(link)
      end
    end
  end

  version_test 2, 'kL375t', %w(
  | downloaded README.md file for custom exercise
  ) do
    manifest = custom_manifest
    refute manifest.keys.include?('exercise')
    manifest['display_name'] = 'C++ Countdown, Round 3'
    readme = Kata_v2.new(externals).send(:readme, manifest)
    assert readme.include?('- Custom exercise: `C++ Countdown, Round 3`'), readme
    refute readme.include?('- Language'), readme
  end

  version_test 2, 'kL375u', %w(
  | downloaded README.md file for non-custom exercise
  ) do
    manifest = custom_manifest
    manifest['exercise'] = "Print Diamond"
    manifest['display_name'] = "Bash, bats"
    readme = Kata_v2.new(externals).send(:readme, manifest)
    assert readme.include?("- Exercise: `Print Diamond`"), readme
    assert readme.include?("- Language & test-framework: `Bash, bats`"), readme
  end

  version_test 2, 'kL375v', %w(
  | download ships committed state, not the working tree. Corrupting the
  | working-tree events.json (as the planned stale-working-tree write path would
  | leave it) does not corrupt the downloaded repo, because download is built
  | from the committed git state, not the working-tree files.
  ) do
    stdout  = { 'content' => '', 'truncated' => false }
    stderr  = { 'content' => '', 'truncated' => false }
    summary = { 'colour' => 'red' }
    in_kata do |id|
      files = kata_event(id, 0)['files']
      kata_ran_tests(id, files, stdout, stderr, '0', summary)
      kata_ran_tests(id, files, stdout, stderr, '1', summary)

      File.write(working_tree_path(id, 'events.json'), 'CORRUPT-NOT-JSON')

      year, month, day = 2021, 7, 11
      externals.instance_exec { @time = TimeStub.new([year, month, day]) }
      tgz_filename, encoded64 = *model.kata_download(id:id)
      Dir.mktmpdir do |tmp_dir|
        File.write("#{tmp_dir}/#{tgz_filename}", Base64.decode64(encoded64))
        shell.assert_cd_exec(tmp_dir, "tar -xf #{tgz_filename}")
        dir_path = "#{tmp_dir}/cyber-dojo-#{year}-#{month}-#{day}-#{id}"
        events = JSON.parse(shell.assert_cd_exec(dir_path, 'cat events.json'))
        assert_equal 3, events.size
      end
    end
  end

end
