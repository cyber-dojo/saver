require_relative 'test_base'
require_source 'model/liner_v0'

class LinerV0Test < TestBase

  include Liner_v0

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B457A5', %w(
  | lined_file('content' => '') returns [''] not []
  | because ''.lines returns []
  ) do
    assert_equal({ 'content' => [''] }, lined_file({ 'content' => '' }))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B457A6', %w(
  | lined_file of an empty stderr keeps its truncated field
  ) do
    empty_stderr = { 'content' => '', 'truncated' => false }
    assert_equal({ 'content' => [''], 'truncated' => false }, lined_file(empty_stderr))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B457AA', %w(
  | lined(event) splits lines files/stdout/stderr and does not alter argument
  ) do
    assert_equal LINED_EVENT, lined(UNLINED_EVENT)
    assert_equal UNLINED_EVENT['files']['test_hiker.rb']['content'], UNLINED_TEST_HIKER_RB
    assert_equal UNLINED_EVENT['files']['hiker.rb']['content'], UNLINED_HIKER_RB
    assert_equal UNLINED_EVENT['stdout']['content'], UNLINED_STDOUT
    assert_equal UNLINED_EVENT['stderr']['content'], UNLINED_STDERR
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B457AB', %w(
  | unlined(event) rejoins files/stdout/stderr and does not alter argument
  ) do
    assert_equal UNLINED_EVENT, unlined(LINED_EVENT)
    assert_equal LINED_EVENT['files']['test_hiker.rb']['content'], LINED_TEST_HIKER_RB
    assert_equal LINED_EVENT['files']['hiker.rb']['content'], LINED_HIKER_RB
    assert_equal LINED_EVENT['stdout']['content'], LINED_STDOUT
    assert_equal LINED_EVENT['stderr']['content'], LINED_STDERR
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B457A3', %w(
  | unlined(event) has truncated fields when event has
  ) do
    lined = {
      'files' => {
        'cyber-dojo.sh' => {
          'content' => ["a\n", "z\n"],
          'truncated' => false
        },
        'readme.txt' => {
          'content' => ["read\n", "me\n", 'blah']
        }
      }
    }
    expected = {
      'files' => {
        'cyber-dojo.sh' => {
          'content' => "a\nz\n",
          'truncated' => false
        },
        'readme.txt' => {
          'content' => "read\nme\nblah"
        }
      }
    }
    assert_equal expected, unlined(lined)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B457A4', %w(
  | lined(event) has truncated fields when event has
  ) do
    unlined = {
      'files' => {
        'cyber-dojo.sh' => {
          'content' => "a\nz\n",
          'truncated' => false
        },
        'readme.txt' => {
          'content' => "read\nme\nblah"
        }
      }
    }
    expected = {
      'files' => {
        'cyber-dojo.sh' => {
          'content' => ["a\n", "z\n"],
          'truncated' => false
        },
        'readme.txt' => {
          'content' => ["read\n", "me\n", 'blah']
        }
      }
    }
    assert_equal expected, lined(unlined)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B457C1', %w(
  | lined(event) lines each of stdout, stderr and status
  | the event has, in every combination of the three
  ) do
    OUTPUT_SETS.each do |keys|
      unlined = UNLINED_EVENT.slice('files', *keys)
      expected = LINED_EVENT.slice('files', *keys)
      assert_equal expected, lined(unlined), keys
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B457C2', %w(
  | unlined(event) rejoins each of stdout, stderr and status
  | the event has, in every combination of the three
  ) do
    OUTPUT_SETS.each do |keys|
      lined = LINED_EVENT.slice('files', *keys)
      expected = UNLINED_EVENT.slice('files', *keys)
      assert_equal expected, unlined(lined), keys
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  OUTPUTS = %w( stdout stderr status ).freeze
  OUTPUT_SETS = (0..OUTPUTS.size).flat_map { |n| OUTPUTS.combination(n).to_a }.freeze

  UNLINED_TEST_HIKER_RB = "require 'sss'\nxxx".freeze
  UNLINED_HIKER_RB = "def x\nend\n".freeze
  UNLINED_STDOUT = "aa\nbb\ncc".freeze
  UNLINED_STDERR = "dd\nee\n".freeze

  UNLINED_EVENT = {
    'files' => {
      'test_hiker.rb' => {
        'content' => UNLINED_TEST_HIKER_RB,
        'truncated' => false
      },
      'hiker.rb' => {
        'content' => UNLINED_HIKER_RB,
        'truncated' => false
      }
    },
    'stdout' => {
      'content' => UNLINED_STDOUT,
      'truncated' => false
    },
    'stderr' => {
      'content' => UNLINED_STDERR,
      'truncated' => false
    },
    'status' => 0
  }.freeze

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  LINED_TEST_HIKER_RB = ["require 'sss'\n", 'xxx'].freeze
  LINED_HIKER_RB = ["def x\n", "end\n"].freeze
  LINED_STDOUT = ["aa\n", "bb\n", 'cc'].freeze
  LINED_STDERR = ["dd\n", "ee\n"].freeze

  LINED_EVENT = {
    'files' => {
      'test_hiker.rb' => {
        'content' => LINED_TEST_HIKER_RB,
        'truncated' => false
      },
      'hiker.rb' => {
        'content' => LINED_HIKER_RB,
        'truncated' => false
      }
    },
    'stdout' => {
      'content' => LINED_STDOUT,
      'truncated' => false
    },
    'stderr' => {
      'content' => LINED_STDERR,
      'truncated' => false
    },
    'status' => 0
  }.freeze
end
