require_relative 'test_base'

class KataRanTestsTest < TestBase

  def self.id58_prefix
    'Sp4'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'Dk1', %w(
  |kata_ran_tests gives same results in all versions
  ) do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      assert_v2_last_commit_message(id, "1 ran tests, no prediction, got red")
      [index, red_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'Dk2', %w(
  |kata_predicted_right gives same results in all versions
  ) do
    in_kata { |id, files, stdout, stderr, status|
      summary = red_summary.merge({'predicted' => 'red' })
      kata_predicted_right(id, index=1, files, stdout, stderr, status, summary)
      assert_v2_last_commit_message(id, "1 ran tests, predicted red, got red")
      [index, summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'Dk3', %w(
  |kata_predicted_wrong gives same results in all versions
  ) do
    in_kata { |id, files, stdout, stderr, status|
      summary = red_summary.merge({ 'predicted' => 'green' })
      kata_predicted_wrong(id, index=1, files, stdout, stderr, status, summary)
      assert_v2_last_commit_message(id, "1 ran tests, predicted green, got red")
      [index, summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'Dk7', %w(
  |kata_reverted gives same results in all versions
  ) do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      kata_ran_tests(id, index=2, files, stdout, stderr, status, red_summary)
      reverted_summary = { "colour" => "red", "revert" => [id, index=1] }
      kata_reverted(id, index=3, files, stdout, stderr, status, reverted_summary)
      expected = JSON.generate({"id":id, "index":1})
      assert_v2_last_commit_message(id, "3 reverted to #{expected}")
      [index, reverted_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'Dk6', %w(
  |kata_checked_out gives same results in all versions
  ) do
    in_kata { |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      group_id = manifest["group_id"]
      group_index = manifest["group_index"]
      id2 = group_join(group_id)
      kata_ran_tests(id2, index=1, files, stdout, stderr, status, red_summary)
      checkout = { "id" => id2, "index" => 1, "avatarIndex" => group_index }
      checkout_out_summary = { "colour" => "red", "checkout" => checkout }
      kata_checked_out(id, index=1, files, stdout, stderr, status, checkout_out_summary)
      expected = JSON.generate(checkout)
      assert_v2_last_commit_message(id, "1 checked out #{expected}")
      [index, checkout_out_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Dk9', %w(
  kata_ran_tests with an already used index raises "Out of order event" exception
  ) do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      error = assert_raises(RuntimeError) {
        kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      }
      assert_equal "Out of order event", error.message
      [index=1, red_summary]
    }
  end

  version_test 2, 'DkA', %w(
  kata_ran_tests with saver-outages backfilled in events
  ) do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=4, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      (2..index-1).each do |n|
        expected = { 'index' => n, 'sub-index' => 0, 'event' => 'outage' }
        assert_equal expected, events[n]
      end
      [index, red_summary]
    }
  end

  private

  def in_kata
    gid = group_create(manifest_Tennis_refactoring_Python_unitttest)
    id = group_join(gid)
    index = 1
    files = {
      "test_hiker.sh" => {
        "content" => "#!/usr/bin/env bats\n\nsource ./hiker.sh\n\n@test \"life the universe and everything\" {\n  local actual=$(answer)\n  [ \"$actual\" == \"42\" ]\n}\n"
      },
      "bats_help.txt" => {
        "content" => "\nbats help is online at\nhttps://github.com/bats-core/bats-core#usage\n"
      },
      "hiker.sh" => {
        "content" => "#!/bin/bash\n\nanswer()\n{\n  echo $((6 * 999sss))\n}\n"
      },
      "cyber-dojo.sh" => {
        "content" => "chmod 700 *.sh\n./test_*.sh\n"
      },
      "readme.txt" => {
        "content" => "Your task is to create an LCD string representation of an\ninteger value using a 3x3 grid of space, underscore, and\npipe characters for each digit. Each digit is shown below\n(using a dot instead of a space)\n\n._.   ...   ._.   ._.   ...   ._.   ._.   ._.   ._.   ._.\n|.|   ..|   ._|   ._|   |_|   |_.   |_.   ..|   |_|   |_|\n|_|   ..|   |_.   ._|   ..|   ._|   |_|   ..|   |_|   ..|\n\n\nExample: 910\n\n._. ... ._.\n|_| ..| |.|\n..| ..| |_|\n"
      }
    }
    stdout = {
      "content" => "1..1\nnot ok 1 life the universe and everything\n# (in test file test_hiker.sh, line 7)\n#   `[ \"$actual\" == \"42\" ]' failed\n# ./hiker.sh: line 5: 6 * 999sss: value too great for base (error token is \"999sss\")\n",
      "truncated" => false
    }
    stderr = {
      "content" => "",
      "truncated" => false
    }
    status = "1"

    index, summary = *yield(id, files, stdout, stderr, status) # <<<<<<<

    actual = kata_event(id, index)
    assert_equal files, actual["files"], :files
    assert_equal stdout, actual["stdout"], :stdout
    assert_equal stderr, actual["stderr"], :stderr
    assert_equal status, actual["status"], :status
    assert_equal index, actual['index'], :index
    summary.keys.each do |key|
      expected = summary[key]
      assert_equal expected, actual[key], key
    end
  end

  def red_summary
    {
      "colour" => "red",
      "duration" => 1.46448,
      "predicted" => "none",
    }
  end

  def assert_v2_last_commit_message(id, expected)
    if version === 2
      dir = '/' + disk.root_dir + "/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
      stdout = shell.assert_cd_exec(dir, "git log --abbrev-commit --pretty=oneline")
      last = stdout.lines[0]
      diagnostic = "\nexpected:#{expected}\n  actual:#{last}"
      assert last.include?(expected), diagnostic
    end
  end

end
