require_relative 'test_base'
require_relative '../src/saver'

class SaverBatchTest < TestBase

  def self.hex_prefix
    '34F'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '414',
  'batch() runs all its commands, not stopping if any return false' do
    dirname = 'batch/e3/t4/14'
    command(true, 'create', dirname)
    command(true, 'exists?', dirname)
    there_no = dirname + '/there-not.txt'
    command(false, 'read', there_no)
    there_yes = dirname + '/there-yes.txt'
    content = 'tulchan spey beat'
    command(true, 'write', there_yes, content)
    command(true, 'append', there_yes, content.reverse)
    command(content+content.reverse, 'read', there_yes)
    command(false, 'read', there_no)
    result = saver.batch(@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_false
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '513', %w(
  batch_until_false()
  stops at exists?() returning false
  and does not execute subsequent commands
  ) do
    dirname = 'batch-until-false/x3/t5/13'
    command(true, 'create', dirname)
    command(true, 'exists?', dirname)
    command(false, 'exists?', dirname+'X')
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'newtyle tay beat'
    not_run('write', filename, content)
    assert_batch_until_false
    assert saver.exists?(dirname)
    refute saver.exists?(dirname+'X')
    refute saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '514', %w(
  batch_until_false()
  stops at create() returning false
  and does not execute subsequent commands
  ) do
    dirname = 'batch-until-false/x3/t5/14'
    command(true, 'create', dirname)
    command(false, 'create', dirname)
    filename = dirname + '/stops-at-exists.txt'
    content = 'newtyle tay beat'
    not_run('write', filename, content)
    assert_batch_until_false
    assert saver.exists?(dirname)
    refute saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '515', %w(
  batch_until_false()
  stops at write() already existing file
  and does not execute subsequent commands
  ) do
    dirname = 'batch-until-false/x3/t5/15'
    command(true, 'create', dirname)
    filename = dirname + '/stops-at-write-false.txt'
    content = 'newtyle tay beat'
    command(true, 'write', filename, content)
    command(false, 'write', filename, content)
    not_run('append', filename, 'extra')
    assert_batch_until_false
    assert saver.exists?(dirname)
    assert_equal content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '516', %w(
  batch_until_false()
  stops at append() to non-existant file
  and does not execute subsequent commands
  ) do
    dirname = 'batch-until-false/x3/t5/16'
    command(true, 'create', dirname)
    filename = dirname + '/stops-at-append-false.txt'
    content = 'newtyle tay beat'
    command(true, 'write', filename, content)
    command(true, 'append', filename, '1')
    command(true, 'append', filename, '2')
    command(false, 'append', filename+'X', '3')
    not_run('append', filename, '4')
    assert_batch_until_false
    assert saver.exists?(dirname)
    assert_equal content+'12', saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '517', %w(
  batch_until_false()
  stops at read() non-existent file
  and does not execute subsequent commands
  ) do
    dirname = 'batch-until-false/x3/t5/17'
    command(true, 'create', dirname)
    filename = dirname + '/stops-at-read-false.txt'
    content = 'inchmarlo dee beat'
    command(true, 'write', filename, content)
    command(false, 'read', filename+'X')
    not_run('append', filename, 'extra')
    assert_batch_until_false
    assert_equal content, saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_true
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  # create 713
  # exists 714
  # write  715
  # append 716

  test '717', %w(
  batch_until_true()
  stops at reading a file that exists
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

    command(false, 'write', dirname + '/3.event.json', '{"colour":"amber"}')
    command(false, 'read',  dirname + '/0.event.json')
    command(false, 'read',  dirname + '/1.event.json')
    command(false, 'read',  dirname + '/2.event.json')
    command(content, 'read',  dirname + '/3.event.json')
    not_run('write', dirname + '/4.event.json', '{"colour":"green"}')

    assert_batch_until_true
    refute saver.read(dirname + '/4.event.json'), :does_not_execute_subsequent_commands
  end

  private

  def command(expected, *command)
    @expected << expected
    @commands << command
  end

  def not_run(*command)
    @commands << command
  end

  def assert_batch_until_false
    result = saver.batch_until_false(@commands)
    assert_equal @expected, result
  end

  def assert_batch_until_true
    result = saver.batch_until_true(@commands)
    assert_equal @expected, result
  end

end
