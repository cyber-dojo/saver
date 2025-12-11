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

  def manifest_Tennis_refactoring_Python_unitttest
    {
      "display_name" => "Tennis refactoring, Python unitttest",
      "filename_extension" => [".py"],
      "image_name" => "cyberdojofoundation/python_unittest:b8333d3",
      "visible_files" => {
        "cyber-dojo.sh" => {
          "content" => "python -m unittest *test*.py\n"
        },
        "readme.txt" => {
          "content" => "Tennis has a rather quirky scoring system, and to newcomers it \ncan be a little difficult to keep track of. The local tennis club\nhas some code that is currently being used to update the scoreboard\nwhen a player scores a point. They has recently acquired two smaller\ntennis clubs, and they two each have a similar piece of code.\n \nYou have just been employed by the tennis club, and your job \nis to refactor all three codebases until you are happy to\nwork with any of them. The future is uncertain, new features may\nbe needed, and you want to be thoroughly on top of your game when\nthat happens.\n \nSummary of Tennis scoring:\n1. A game is won by the first player to have won at least four points \n   in total and at least two points more than the opponent.\n2. The running score of each game is described in a manner peculiar \n   to tennis: scores from zero to three points are described as “love”, \n   “fifteen”, “thirty”, and “forty” respectively.\n3. If at least three points have been scored by each player, and the \n   scores are equal, the score is “deuce”.\n4. If at least three points have been scored by each side and a player\n   has one more point than his opponent, the score of the game is\n   “advantage” for the player in the lead."
        },
        "tennis.py" => {
          "content" => "# -*- coding: utf-8 -*-\n\nclass TennisGame1:\n\n    def __init__(self, player1Name, player2Name):\n        self.player1Name = player1Name\n        self.player2Name = player2Name\n        self.p1points = 0\n        self.p2points = 0\n        \n    def won_point(self, playerName):\n        if playerName == self.player1Name:\n            self.p1points += 1\n        else:\n            self.p2points += 1\n    \n    def score(self):\n        result = \"\"\n        tempScore=0\n        if (self.p1points==self.p2points):\n            result = {\n                0 : \"Love-All\",\n                1 : \"Fifteen-All\",\n                2 : \"Thirty-All\",\n            }.get(self.p1points, \"Deuce\")\n        elif (self.p1points>=4 or self.p2points>=4):\n            minusResult = self.p1points-self.p2points\n            if (minusResult==1):\n                result =\"Advantage \" + self.player1Name\n            elif (minusResult ==-1):\n                result =\"Advantage \" + self.player2Name\n            elif (minusResult>=2):\n                result = \"Win for \" + self.player1Name\n            else:\n                result =\"Win for \" + self.player2Name\n        else:\n            for i in range(1,3):\n                if (i==1):\n                    tempScore = self.p1points\n                else:\n                    result+=\"-\"\n                    tempScore = self.p2points\n                result += {\n                    0 : \"Love\",\n                    1 : \"Fifteen\",\n                    2 : \"Thirty\",\n                    3 : \"Forty\",\n                }[tempScore]\n        return result\n\n\nclass TennisGame2:\n    def __init__(self, player1Name, player2Name):\n        self.player1Name = player1Name\n        self.player2Name = player2Name\n        self.p1points = 0\n        self.p2points = 0\n        \n    def won_point(self, playerName):\n        if playerName == self.player1Name:\n            self.P1Score()\n        else:\n            self.P2Score()\n    \n    def score(self):\n        result = \"\"\n        if (self.p1points == self.p2points and self.p1points < 3):\n            if (self.p1points==0):\n                result = \"Love\"\n            if (self.p1points==1):\n                result = \"Fifteen\"\n            if (self.p1points==2):\n                result = \"Thirty\"\n            result += \"-All\"\n        if (self.p1points==self.p2points and self.p1points>2):\n            result = \"Deuce\"\n        \n        P1res = \"\"\n        P2res = \"\"\n        if (self.p1points > 0 and self.p2points==0):\n            if (self.p1points==1):\n                P1res = \"Fifteen\"\n            if (self.p1points==2):\n                P1res = \"Thirty\"\n            if (self.p1points==3):\n                P1res = \"Forty\"\n            \n            P2res = \"Love\"\n            result = P1res + \"-\" + P2res\n        if (self.p2points > 0 and self.p1points==0):\n            if (self.p2points==1):\n                P2res = \"Fifteen\"\n            if (self.p2points==2):\n                P2res = \"Thirty\"\n            if (self.p2points==3):\n                P2res = \"Forty\"\n            \n            P1res = \"Love\"\n            result = P1res + \"-\" + P2res\n        \n        \n        if (self.p1points>self.p2points and self.p1points < 4):\n            if (self.p1points==2):\n                P1res=\"Thirty\"\n            if (self.p1points==3):\n                P1res=\"Forty\"\n            if (self.p2points==1):\n                P2res=\"Fifteen\"\n            if (self.p2points==2):\n                P2res=\"Thirty\"\n            result = P1res + \"-\" + P2res\n        if (self.p2points>self.p1points and self.p2points < 4):\n            if (self.p2points==2):\n                P2res=\"Thirty\"\n            if (self.p2points==3):\n                P2res=\"Forty\"\n            if (self.p1points==1):\n                P1res=\"Fifteen\"\n            if (self.p1points==2):\n                P1res=\"Thirty\"\n            result = P1res + \"-\" + P2res\n        \n        if (self.p1points > self.p2points and self.p2points >= 3):\n            result = \"Advantage \" + self.player1Name\n        \n        if (self.p2points > self.p1points and self.p1points >= 3):\n            result = \"Advantage \" + self.player2Name\n        \n        if (self.p1points>=4 and self.p2points>=0 and (self.p1points-self.p2points)>=2):\n            result = \"Win for \" + self.player1Name\n        if (self.p2points>=4 and self.p1points>=0 and (self.p2points-self.p1points)>=2):\n            result = \"Win for \" + self.player2Name\n        return result\n    \n    def SetP1Score(self, number):\n        for i in range(number):\n            self.P1Score()\n    \n    def SetP2Score(self, number):\n        for i in range(number):\n            self.P2Score()\n    \n    def P1Score(self):\n        self.p1points +=1\n    \n    \n    def P2Score(self):\n        self.p2points +=1\n        \nclass TennisGame3:\n    def __init__(self, player1Name, player2Name):\n        self.p1N = player1Name\n        self.p2N = player2Name\n        self.p1 = 0\n        self.p2 = 0\n        \n    def won_point(self, n):\n        if n == self.p1N:\n            self.p1 += 1\n        else:\n            self.p2 += 1\n    \n    def score(self):\n        if (self.p1 < 4 and self.p2 < 4) and (self.p1 + self.p2 < 6):\n            p = [\"Love\", \"Fifteen\", \"Thirty\", \"Forty\"]\n            s = p[self.p1]\n            return s + \"-All\" if (self.p1 == self.p2) else s + \"-\" + p[self.p2]\n        else:\n            if (self.p1 == self.p2):\n                return \"Deuce\"\n            s = self.p1N if self.p1 > self.p2 else self.p2N\n            return \"Advantage \" + s if ((self.p1-self.p2)*(self.p1-self.p2) == 1) else \"Win for \" + s\n"
        },
        "tennis_unit_test.py" => {
          "content" => "# -*- coding: utf-8 -*-\n\nimport unittest\n\nfrom tennis import TennisGame1, TennisGame2, TennisGame3\n\ntest_cases = [\n    (0, 0, \"Love-All\", 'player1', 'player2'),\n    (1, 1, \"Fifteen-All\", 'player1', 'player2'),\n    (2, 2, \"Thirty-All\", 'player1', 'player2'),\n    (3, 3, \"Deuce\", 'player1', 'player2'),\n    (4, 4, \"Deuce\", 'player1', 'player2'),\n\n    (1, 0, \"Fifteen-Love\", 'player1', 'player2'),\n    (0, 1, \"Love-Fifteen\", 'player1', 'player2'),\n    (2, 0, \"Thirty-Love\", 'player1', 'player2'),\n    (0, 2, \"Love-Thirty\", 'player1', 'player2'),\n    (3, 0, \"Forty-Love\", 'player1', 'player2'),\n    (0, 3, \"Love-Forty\", 'player1', 'player2'),\n    (4, 0, \"Win for player1\", 'player1', 'player2'),\n    (0, 4, \"Win for player2\", 'player1', 'player2'),\n\n    (2, 1, \"Thirty-Fifteen\", 'player1', 'player2'),\n    (1, 2, \"Fifteen-Thirty\", 'player1', 'player2'),\n    (3, 1, \"Forty-Fifteen\", 'player1', 'player2'),\n    (1, 3, \"Fifteen-Forty\", 'player1', 'player2'),\n    (4, 1, \"Win for player1\", 'player1', 'player2'),\n    (1, 4, \"Win for player2\", 'player1', 'player2'),\n\n    (3, 2, \"Forty-Thirty\", 'player1', 'player2'),\n    (2, 3, \"Thirty-Forty\", 'player1', 'player2'),\n    (4, 2, \"Win for player1\", 'player1', 'player2'),\n    (2, 4, \"Win for player2\", 'player1', 'player2'),\n\n    (4, 3, \"Advantage player1\", 'player1', 'player2'),\n    (3, 4, \"Advantage player2\", 'player1', 'player2'),\n    (5, 4, \"Advantage player1\", 'player1', 'player2'),\n    (4, 5, \"Advantage player2\", 'player1', 'player2'),\n    (15, 14, \"Advantage player1\", 'player1', 'player2'),\n    (14, 15, \"Advantage player2\", 'player1', 'player2'),\n\n    (6, 4, 'Win for player1', 'player1', 'player2'), \n    (4, 6, 'Win for player2', 'player1', 'player2'), \n    (16, 14, 'Win for player1', 'player1', 'player2'), \n    (14, 16, 'Win for player2', 'player1', 'player2'), \n\n    (6, 4, 'Win for One', 'One', 'player2'),\n    (4, 6, 'Win for Two', 'player1', 'Two'), \n    (6, 5, 'Advantage One', 'One', 'player2'),\n    (5, 6, 'Advantage Two', 'player1', 'Two'), \n    \n    ]\n\ndef play_game(TennisGame, p1Points, p2Points, p1Name, p2Name):\n    game = TennisGame(p1Name, p2Name)\n    for i in range(max(p1Points, p2Points)):\n        if i < p1Points:\n            game.won_point(p1Name)\n        if i < p2Points:\n            game.won_point(p2Name)\n    return game\n\nclass TestTennis(unittest.TestCase):\n     \n    def test_Score_Game1(self):\n        for testcase in test_cases:\n            (p1Points, p2Points, score, p1Name, p2Name) = testcase\n            game = play_game(TennisGame1, p1Points, p2Points, p1Name, p2Name)\n            self.assertEqual(score, game.score())\n\n    def test_Score_Game2(self):\n        for testcase in test_cases:\n            (p1Points, p2Points, score, p1Name, p2Name) = testcase\n            game = play_game(TennisGame2, p1Points, p2Points, p1Name, p2Name)\n            self.assertEqual(score, game.score())\n\n    def test_Score_Game3(self):\n        for testcase in test_cases:\n            (p1Points, p2Points, score, p1Name, p2Name) = testcase\n            game = play_game(TennisGame3, p1Points, p2Points, p1Name, p2Name)\n            self.assertEqual(score, game.score())\n \nif __name__ == \"__main__\":\n    unittest.main() \n        "
          }
       }
    }.clone
  end

  def bats
    {
      'files' => {
        'test_hiker.sh' => {
          'content' => "#!/usr/bin/env bats\n\nsource ./hiker.sh\n\n@test \"life the universe and everything\" {\n  local actual=$(answer)\n  [ \"$actual\" == \"42\" ]\n}\n"
        },
        'bats_help.txt' => {
          'content' => "\nbats help is online at\nhttps://github.com/bats-core/bats-core#usage\n"
        },
        'hiker.sh' => {
          'content' => "#!/bin/bash\n\nanswer()\n{\n  echo $((6 * 999sss))\n}\n"
        },
        'cyber-dojo.sh' => {
          'content' => "chmod 700 *.sh\n./test_*.sh\n"
        },
        'readme.txt' => {
          'content' => "Your task is to create an LCD string representation of an\ninteger value using a 3x3 grid of space, underscore, and\npipe characters for each digit. Each digit is shown below\n(using a dot instead of a space)\n\n._.   ...   ._.   ._.   ...   ._.   ._.   ._.   ._.   ._.\n|.|   ..|   ._|   ._|   |_|   |_.   |_.   ..|   |_|   |_|\n|_|   ..|   |_.   ._|   ..|   ._|   |_|   ..|   |_|   ..|\n\n\nExample: 910\n\n._. ... ._.\n|_| ..| |.|\n..| ..| |_|\n"
        }
      },
      'stdout' => {
        'content' => "1..1\nnot ok 1 life the universe and everything\n# (in test file test_hiker.sh, line 7)\n#   `[ \"$actual\" == \"42\" ]' failed\n# ./hiker.sh: line 5: 6 * 999sss: value too great for base (error token is \"999sss\")\n",
        'truncated' => false
      },
      'stderr' => {
        'content' => '',
        'truncated' => false
      },
      'status' => '1'
    }.clone
  end

  def red_summary
    {
      'colour' => 'red',
      'duration' => 1.46448,
      'predicted' => 'none',
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
    actual["files"].each do |key,a_value|
      e_value = nil
      if expected.has_key?("files") && expected["files"].is_a?(Hash)
        e_value = expected["files"][key]
      else
        e_value = nil
      end
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
