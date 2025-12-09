require_relative 'test_base'

class KataFileEditTest < TestBase

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A57', %w(
  |kata_file_edit does NOT create an event 
  |when the incoming files are identical to the existing most-recent files.
  ) do
    in_kata { |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      kata_edit_files(id, index=2, files)
      events = kata_events(id)
      assert_equal 2, events.size
      event2 = events[-1]
      assert_equal 1, event2['index']
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A58', %w(
  |kata_file_edit creates a NEW event 
  |when the incoming files are NOT identical to the existing most-recent files.
  ) do
    in_kata { |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      files['readme.txt']['content'] += 'Hello world'

      kata_edit_files(id, index=2, files)
      events = kata_events(id)
      assert_equal 3, events.size
      event2 = events[-1]
      assert_equal 2, event2['index']
    }
  end

  private

  def in_kata
    id = kata_create(manifest_Tennis_refactoring_Python_unitttest)
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

    yield(id, files, stdout, stderr, status)    
  end

  def red_summary
    {
      "colour" => "red",
      "duration" => 1.46448,
      "predicted" => "none",
    }
  end
end
