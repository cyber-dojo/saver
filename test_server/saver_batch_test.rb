require_relative 'test_base'
require_relative '../src/saver'

class SaverBatchTest < TestBase

  def self.hex_prefix
    '34F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '514',
  'batch() runs all its commands, not stopping if any return false' do
    expected = []
    commands = []

    dirname = 'batch/e3/t6/A8'
    commands << ['create',dirname]
    expected << true

    commands << ['exists?',dirname]
    expected << true

    there_no = dirname + '/there-not.txt'
    commands << ['read',there_no]
    expected << false

    there_yes = dirname + '/there-yes.txt'
    content = 'tulchan spey beat'
    commands << ['write',there_yes,content]
    expected << true

    commands << ['append',there_yes,content.reverse]
    expected << true

    commands << ['read',there_yes]
    expected << content+content.reverse

    commands << ['read',there_no]
    expected << false

    result = saver.batch(commands)
    assert_equal expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_false
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '515', %w(
  batch_until_false() runs its commands
  stopping at the first one that returns false
  and does not execute subsequent commands
  ) do
    expected = []
    commands = []

    dirname = 'batch-until-false/x3/t5/15'
    commands << ['create',dirname]
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo tay beat'
    commands << ['write',there_yes,content]
    expected << true

    there_no = dirname + '/there-not.txt'
    commands << ['read',there_no]
    expected << false # <------

    commands << ['append',there_yes,'extra'] # would be true

    result = saver.batch_until_false(commands)
    assert_equal expected, result, :stopped_at_false
    assert_equal content, saver.read(there_yes), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '516', %w(
  batch_until_false() propagates an exception
  when write command raises an exception (writing existing file)
  and does not execute subsequent commands
  ) do
    expected = []
    commands = []

    dirname = 'batch-until-false/x3/t5/16'
    commands << ['create',dirname]
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'newtyle tay beat'
    commands << ['write',there_yes,content]
    expected << true

    commands << ['write',there_yes,content]
    expected << false

    commands << ['append',there_yes,'extra'] # not-run

    result = saver.batch_until_false(commands)
    assert_equal expected, result
    assert saver.exists?(dirname)
    assert_equal content, saver.read(there_yes)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_true
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '715', %w(
  batch_until_true() runs its commands
  swallowing known exceptions
  and stopping at the first one that returns true
  and does not execute subsequent commands
  ) do
    dirname = 'batch-until-true/x3/t7/15'
    event_3 = dirname + '/3.event.json'
    content = '{"colour":"red"}'

    result = saver.batch([
      ['create',dirname],
      ['write',event_3,content]
    ])
    assert_equal [true,true], result, :setup

    commands = [
      ['write', dirname + '/3.event.json', '{"colour":"amber"}'],
      ['read',  dirname + '/0.event.json'],
      ['read',  dirname + '/1.event.json'],
      ['read',  dirname + '/2.event.json'],
      ['read',  dirname + '/3.event.json'],
      ['write', dirname + '/4.event.json', '{"colour":"green"}']
    ]
    expected = [false,false,false,false,content]
    result = saver.batch_until_true(commands)
    assert_equal expected, result, :stopped_at_true
    refute saver.read(dirname + '/4.event.json'), :does_not_execute_subsequent_commands
  end

end
