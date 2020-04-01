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
    commands = []

    dirname = 'batch-until-false/x3/t5/16'
    commands << ['create',dirname] # true

    there_yes = dirname + '/there-yes.txt'
    content = 'newtyle tay beat'
    commands << ['write',there_yes,content] # true

    commands << ['write',there_yes,content] # raises <------------

    commands << ['append',there_yes,'extra'] # not-run

    _error = assert_raises(Errno::EEXIST) {
      saver.batch_until_false(commands)
    }
    assert saver.exists?(dirname)
    assert_equal content, saver.read(there_yes)
  end

end
