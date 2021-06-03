require_relative 'test_base'

class KataRanTestsTest < TestBase

  def self.id58_prefix
    'Sp4'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'XX2', %w(
  |kata_ran_tests gives same results in all versions
  ) do
    universal_append { |id, index, files, stdout, stderr, status|
      summary = {
        "colour" => "red",
        "duration" => 1.46448,
        "predicted" => "none",
      }
      kata_ran_tests(id, index, files, stdout, stderr, status, summary)
      summary
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'Dk2', %w(
  |kata_predicted_right gives same results in all versions
  ) do
    universal_append { |id, index, files, stdout, stderr, status|
      summary = {
        "colour" => "red",
        "duration" => 1.46448,
        "predicted" => "red",
      }
      kata_predicted_right(id, index, files, stdout, stderr, status, summary)
      summary
    }
  end

  versions3_test 'Dk3', %w(
  |kata_predicted_wrong gives same results in all versions
  ) do
    universal_append { |id, index, files, stdout, stderr, status|
      summary = {
        "colour" => "red",
        "duration" => 1.46448,
        "predicted" => "green",
      }
      kata_predicted_wrong(id, index, files, stdout, stderr, status, summary)
      summary
    }
  end

  versions3_test 'Dk7', %w(
  |kata_reverted gives same results in all versions
  ) do
    universal_append { |id, index, files, stdout, stderr, status|
      summary = {
        #TODO
      }
      kata_reverted(id, index, files, stdout, stderr, status, summary)
      summary
    }
  end

  versions3_test 'Dk6', %w(
  |kata_checked_out gives same results in all versions
  ) do
    universal_append { |id, index, files, stdout, stderr, status|
      summary = {
        #TODO
      }
      kata_checked_out(id, index, files, stdout, stderr, status, summary)
      summary
    }
  end

  private

  def universal_append
    t0 = [2020,11,1, 5,6,18,654318]
    t1 = [2020,11,1, 5,7,23,883467]
    externals.instance_exec { @time = TimeStub.new(t0,t1) }
    manifest = custom_manifest
    manifest['version'] = version
    id = kata_create(manifest, default_options)
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

    summary = yield(id, index, files, stdout, stderr, status)

    actual = kata_event(id, index)
    assert_equal files, actual["files"], :files

    assert_equal stdout, actual["stdout"], :stdout
    assert_equal stderr, actual["stderr"], :stderr
    assert_equal status, actual["status"], :status

    assert_equal index, actual['index'], :index
    assert_equal t1, actual['time'], :time

    summary.keys.each do |key|
      expected = summary[key]
      assert_equal expected, actual[key], key
    end
  end

end
