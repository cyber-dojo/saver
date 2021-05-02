# frozen_string_literal: true

module KataTestData

  V0_KATA_ID = 'k5ZTk0'
  V1_KATA_ID = 'rUqcey'

  def kata_event_rUqcey_1
    return {
      "files" => {
        "test_hiker.py" => {
          "content" => "from hiker import global_answer, Hiker\nimport unittest\n\n\nclass TestHiker(unittest.TestCase):\n\n    def test_global_function(self):\n        self.assertEqual(42, global_answer())\n\n    def test_instance_method(self):\n        self.assertEqual(42, Hiker().instance_answer())\n\n\nif __name__ == '__main__':\n    unittest.main()  # pragma: no cover\n"
        },
        "hiker.py" => {
          "content" => "'''The starting files are unrelated to the exercise.\n\nThey simply show syntax for writing and testing\n  o) a global function\n  o) an instance method\nPick the style that best fits the exercise.\nThen delete the other one, along with this comment!\n'''\n\ndef global_answer():\n    return 6 * 7\n\nclass Hiker:\n\n    def instance_answer(self):\n        return global_answer()\n"
        },
        "cyber-dojo.sh" => {
          "content" => "set -e\n\n# --------------------------------------------------------------\n# Text files under /sandbox are automatically returned...\nsource ~/cyber_dojo_fs_cleaners.sh\nexport REPORT_DIR=${CYBER_DOJO_SANDBOX}/report\nfunction cyber_dojo_enter()\n{\n  # 1. Only return _newly_ generated reports.\n  cyber_dojo_reset_dirs ${REPORT_DIR}\n}\nfunction cyber_dojo_exit()\n{\n  # 2. Remove text files we don't want returned.\n  cyber_dojo_delete_dirs .pytest_cache # ...\n  #cyber_dojo_delete_files ...\n}\ncyber_dojo_enter\ntrap cyber_dojo_exit EXIT SIGTERM\n# --------------------------------------------------------------\n\ncoverage3 run \\\n  --source=${CYBER_DOJO_SANDBOX} \\\n  --module unittest \\\n  *test*.py\n\n# https://coverage.readthedocs.io/en/v4.5.x/index.html\n\ncoverage3 report \\\n  --show-missing \\\n    > ${REPORT_DIR}/coverage.txt\n\n# http://pycodestyle.pycqa.org/en/latest/intro.html#configuration\n\npycodestyle \\\n  ${CYBER_DOJO_SANDBOX} \\\n    --show-source `# show source code for each error` \\\n    --show-pep8   `# show relevent text from pep8` \\\n    --ignore E302,E305,W293 \\\n    --max-line-length=80 \\\n      > ${REPORT_DIR}/style.txt\n\n# E302 expected 2 blank lines, found 0\n# E305 expected 2 blank lines after end of function or class\n# W293 blank line contains whitespace\n"
        },
        "readme.txt" => {
          "content" => "Write a program that prints the numbers from 1 to 100, but...\n\nnumbers that are exact multiples of 3, or that contain 3, must print a string containing \"Fizz\"\n   For example 9 -> \"...Fizz...\"\n   For example 31 -> \"...Fizz...\"\n\nnumbers that are exact multiples of 5, or that contain 5, must print a string containing \"Buzz\"\n   For example 10 -> \"...Buzz...\"\n   For example 51 -> \"...Buzz...\"\n"
        },
        "report/style.txt" => {
          "content" => "",
          "truncated" => false
        },
        "report/coverage.txt" => {
          "content" => "Name            Stmts   Miss  Cover   Missing\n---------------------------------------------\nhiker.py            5      0   100%\ntest_hiker.py       8      0   100%\n---------------------------------------------\nTOTAL              13      0   100%\n",
          "truncated" => false
        }
      },
      "stdout" => {
        "content" => "",
        "truncated" => false
      },
      "stderr" => {
        "content" => "..\n----------------------------------------------------------------------\nRan 2 tests in 0.001s\n\nOK\n",
        "truncated" => false
      },
      "status" => "0",
      "duration" => 2.726096,
      "colour" => "green",
      "predicted" => "none",
      "index" => 1,
      "time" => [2020,11,30, 14,6,39, 366362]
    }
  end

  def kata_event_rUqcey_2
    return {
      "files" => {
        "test_hiker.py" => {
          "content" => "from hiker import global_answer, Hiker\nimport unittest\n\n\nclass TestHiker(unittest.TestCase):\n\n    def test_global_function(self):\n        self.assertEqual(42, global_answer())\n\n    def test_instance_method(self):\n        self.assertEqual(42, Hiker().instance_answer())\n\n    def test_global_function2(self):\n        self.assertEqual(42, global_answer())\n\n    def test_instance_method2(self):\n        self.assertEqual(42, Hiker().instance_answer())\n        \n\nif __name__ == '__main__':\n    unittest.main()  # pragma: no cover\n"
        },
        "hiker.py" => {
          "content" => "'''The starting files are unrelated to the exercise.\n\nThey simply show syntax for writing and testing\n  o) a global function\n  o) an instance method\nPick the style that best fits the exercise.\nThen delete the other one, along with this comment!\n'''\n\ndef global_answer():\n    return 6 * 7\n\nclass Hiker:\n\n    def instance_answer(self):\n        return global_answer()\n"
        },
        "cyber-dojo.sh" => {
          "content" => "set -e\n\n# --------------------------------------------------------------\n# Text files under /sandbox are automatically returned...\nsource ~/cyber_dojo_fs_cleaners.sh\nexport REPORT_DIR=${CYBER_DOJO_SANDBOX}/report\nfunction cyber_dojo_enter()\n{\n  # 1. Only return _newly_ generated reports.\n  cyber_dojo_reset_dirs ${REPORT_DIR}\n}\nfunction cyber_dojo_exit()\n{\n  # 2. Remove text files we don't want returned.\n  cyber_dojo_delete_dirs .pytest_cache # ...\n  #cyber_dojo_delete_files ...\n}\ncyber_dojo_enter\ntrap cyber_dojo_exit EXIT SIGTERM\n# --------------------------------------------------------------\n\ncoverage3 run \\\n  --source=${CYBER_DOJO_SANDBOX} \\\n  --module unittest \\\n  *test*.py\n\n# https://coverage.readthedocs.io/en/v4.5.x/index.html\n\ncoverage3 report \\\n  --show-missing \\\n    > ${REPORT_DIR}/coverage.txt\n\n# http://pycodestyle.pycqa.org/en/latest/intro.html#configuration\n\npycodestyle \\\n  ${CYBER_DOJO_SANDBOX} \\\n    --show-source `# show source code for each error` \\\n    --show-pep8   `# show relevent text from pep8` \\\n    --ignore E302,E305,W293 \\\n    --max-line-length=80 \\\n      > ${REPORT_DIR}/style.txt\n\n# E302 expected 2 blank lines, found 0\n# E305 expected 2 blank lines after end of function or class\n# W293 blank line contains whitespace\n"
        },
        "readme.txt" => {
          "content" => "Write a program that prints the numbers from 1 to 100, but...\n\nnumbers that are exact multiples of 3, or that contain 3, must print a string containing \"Fizz\"\n   For example 9 -> \"...Fizz...\"\n   For example 31 -> \"...Fizz...\"\n\nnumbers that are exact multiples of 5, or that contain 5, must print a string containing \"Buzz\"\n   For example 10 -> \"...Buzz...\"\n   For example 51 -> \"...Buzz...\"\n"
        },
        "report/style.txt" => {
          "content" => ""
        },
        "report/coverage.txt" => {
          "content" => "Name            Stmts   Miss  Cover   Missing\n---------------------------------------------\nhiker.py            5      0   100%\ntest_hiker.py      12      0   100%\n---------------------------------------------\nTOTAL              17      0   100%\n",
          "truncated" => false
        }
      },
      "stdout" => {
        "content" => "",
        "truncated" => false
      },
      "stderr" => {
        "content" => "....\n----------------------------------------------------------------------\nRan 4 tests in 0.000s\n\nOK\n",
        "truncated" => false
      },
      "status" => "0",
      "duration" => 1.891786,
      "colour" => "green",
      "predicted" => "none",
      "index" => 2,
      "time" => [2020,11,30, 14,6,53, 941739]
    }
  end

  def kata_event_k5ZTk0_2
    return {
      "files" => {
        "test_hiker.rb" => {
          "content" => "require_relative 'coverage'\nrequire_relative 'hiker'\nrequire 'minitest/autorun'\n\nclass TestHiker < MiniTest::Test\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n"}, "hiker.rb"=>{"content"=>"\ndef answer\n  6 * 999dfdf\nend\n"
        },
        "cyber-dojo.sh" => {
          "content" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n"
        },
        "coverage.rb" => {
          "content" => "require 'simplecov'\nrequire 'simplecov-console'\nSimpleCov.formatter = SimpleCov::Formatter::Console\nSimpleCov.start\n"
        },
        "readme.txt" => {
          "content" => "There are four types of common coins in US currency:\n  quarters (25 cents)\n  dimes (10 cents)\n  nickels (5 cents) \n  pennies (1 cent)\n  \nThere are 6 ways to make change for 15 cents:\n  A dime and a nickel;\n  A dime and 5 pennies;\n  3 nickels;\n  2 nickels and 5 pennies;\n  A nickel and 10 pennies;\n  15 pennies.\n  \nHow many ways are there to make change for a dollar\nusing these common coins? (1 dollar = 100 cents).\n\n[Source http://rosettacode.org]"
        }
      },
      "stdout" => {
        "content" => "\nCOVERAGE: 100.00% -- 0/0 lines in 1 files\n",
        "truncated" => false
      },
      "stderr" => {
        "content" => "SimpleCov failed to recognize the test framework and/or suite used. Please specify manually using SimpleCov.command_name 'Unit Tests'.\ntest_hiker.rb:2:in `require_relative': /sandbox/hiker.rb:3: syntax error, unexpected tIDENTIFIER, expecting keyword_end (SyntaxError)\n  6 * 999dfdf\n         ^~~~\n\tfrom test_hiker.rb:2:in `<main>'\n",
        "truncated" => false
      },
      "status" => "1",
      "colour" => "amber",
      "duration" => 1.1275,
      "predicted" => "none",
      "index" => 2,
      "time" => [2019,1,19, 12,45,26, 76791]
    }
  end

  def kata_event_k5ZTk0_3
    return {
      "files" => {
        "test_hiker.rb" => {
          "content" => "require_relative 'coverage'\nrequire_relative 'hiker'\nrequire 'minitest/autorun'\n\nclass TestHiker < MiniTest::Test\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n"
        },
        "hiker.rb" => {
          "content" => "\ndef answer\n  6 * 7\nend\n"
        },
        "cyber-dojo.sh" => {
          "content" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n"
        },
        "coverage.rb" => {
          "content" => "require 'simplecov'\nrequire 'simplecov-console'\nSimpleCov.formatter = SimpleCov::Formatter::Console\nSimpleCov.start\n"}, "readme.txt"=>{"content"=>"There are four types of common coins in US currency:\n  quarters (25 cents)\n  dimes (10 cents)\n  nickels (5 cents) \n  pennies (1 cent)\n  \nThere are 6 ways to make change for 15 cents:\n  A dime and a nickel;\n  A dime and 5 pennies;\n  3 nickels;\n  2 nickels and 5 pennies;\n  A nickel and 10 pennies;\n  15 pennies.\n  \nHow many ways are there to make change for a dollar\nusing these common coins? (1 dollar = 100 cents).\n\n[Source http://rosettacode.org]"
        }
      },
      "stdout" => {
        "content" => "Run options: --seed 49500\n\n# Running:\n\n.\n\nFinished in 0.001027s, 974.0986 runs/s, 974.0986 assertions/s.\n\n1 runs, 1 assertions, 0 failures, 0 errors, 0 skips\n\nCOVERAGE: 100.00% -- 2/2 lines in 1 files\n",
        "truncated" => false
      },
      "stderr" => {
        "content" => "",
        "truncated" => false
      },
      "status" => "0",
      "colour" => "green",
      "duration" => 1.072198,
      "predicted" => "none",
      "index" => 3,
      "time" => [2019,1,19, 12,45,30, 656924]
    }
  end

=begin
  def print_cmp(expected, actual)
    actual.each do |key,value|
      if expected[key] == actual[key]
        p("key #{key}: SAME")
      else
        p("key #{key}: NOT SAME")
      end
    end
    expected["files"].each do |key,e_value|
      a_value = actual["files"][key]
      if e_value == a_value
        p("key ['files'][#{key}] : SAME")
      else
        p("key ['files'][#{key}] : NOT SAME")
        expected["files"][key].each do |key2,e_value|
          a_value = actual['files'][key][key2]
          if e_value == a_value
            p(" ['files'][#{key}][#{key2}] : SAME")
          else
            p(" ['files'][#{key}][#{key2}] : NOT SAME")
            p('expected')
            p(e_value)
            p('actual')
            p(a_value)
          end
        end
      end
    end
  end
=end

end
