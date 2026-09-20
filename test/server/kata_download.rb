require_relative 'test_base'
require_source 'model/kata_v2'
require 'base64'
require 'tmpdir'

class KataDownloadTest < TestBase

  version_test 2, 'kL375s', %w(
  | kata_download returns a base64 .tgz which the real tar extracts.
  | Its root dir is named cyber-dojo-<year>-<month>-<day>-<id>.
  | The extracted dir holds a git repo with one tag and one commit per event.
  | The commits come newest first and each tag sits on its own index's commit.
  | The checkout is clean.
  | The repo carries the kata's cyber-dojo.sh and a README.md linking to it.
  | The repo has no remote.
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
        untar(Base64.decode64(encoded64), tmp_dir)
        dir_name = "cyber-dojo-#{year}-#{month}-#{day}-#{id}"
        dir_path = "#{tmp_dir}/#{dir_name}"
        assert File.directory?(dir_path), dir_path
        assert File.directory?("#{dir_path}/.git"), dir_path
        # tags are exactly 0,1,2 (names, not just count)
        tags = `cd #{dir_path} && git tag`
        assert_equal %w(0 1 2), tags.split("\n").sort
        # full history: one commit per event, right messages, newest first
        subjects = `cd #{dir_path} && git log --pretty=%s`
        assert_equal [
          '2 ran tests, no prediction, got red',
          '1 ran tests, no prediction, got red',
          '0 kata creation',
        ], subjects.split("\n")
        # each tag points at the commit for its index (commit<->tag correspondence)
        %w(0 1 2).each do |i|
          subject = `cd #{dir_path} && git log -1 --pretty=%s #{i}`
          assert subject.start_with?("#{i} "), "tag #{i} -> #{subject}"
        end
        # working tree is checked out clean at HEAD (nothing missing or modified)
        status = `cd #{dir_path} && git status --porcelain`
        assert_equal '', status, status
        # no remote, so nothing points back at saver's disk
        remotes = `cd #{dir_path} && git remote -v 2>&1`
        assert_equal '', remotes, remotes
        actual_cyber_dojo_sh = File.read("#{dir_path}/files/cyber-dojo.sh")
        assert_equal expected_cyber_dojo_sh, actual_cyber_dojo_sh
        readme_md = File.read("#{dir_path}/README.md")
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
      _tgz_filename, encoded64 = *model.kata_download(id:id)
      Dir.mktmpdir do |tmp_dir|
        untar(Base64.decode64(encoded64), tmp_dir)
        dir_path = "#{tmp_dir}/cyber-dojo-#{year}-#{month}-#{day}-#{id}"
        events = JSON.parse(File.read("#{dir_path}/events.json"))
        assert_equal 3, events.size
      end
    end
  end

  private

  # Extracts the tgz under <dir> with the real tar, so the download is inspected
  # as the directory tree and git repo a user gets. Deliberately not saver's own
  # TGZ reader: extracting with the same library that wrote the tarball would
  # only show that saver can read back what it wrote, and the tarball has to
  # open with the tar a user actually has. tar's verbose output is captured so a
  # passing test stays silent.
  def untar(tgz, dir)
    File.binwrite("#{dir}/kata.tgz", tgz)
    output = `cd #{dir} && tar -xvf kata.tgz 2>&1`
    assert_equal 0, $?.exitstatus, output
  end

end
