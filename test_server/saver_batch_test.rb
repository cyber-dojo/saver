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

  test '314',
  'batch_run() runs all its commands, not stopping when any return false' do
    dirname = 'batch/e3/t3/14'
    command(true, create_command(dirname))
    command(true, exists_command(dirname))
    there_no = dirname + '/there-not.txt'
    command(false, read_command(there_no))
    there_yes = dirname + '/there-yes.txt'
    content = 'tulchan spey beat'
    command(true, write_command(there_yes, content))
    command(true, append_command(there_yes, content.reverse))
    command(content+content.reverse, read_command(there_yes))
    command(false, read_command(there_no))
    result = saver.batch_run(@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_assert
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '416',
  'batch_assert() returns array of results when all commands are true' do
    dirname = 'batch/e3/t4/16'
    command(true, create_command(dirname))
    command(true, exists_command(dirname))
    there_yes = dirname + '/there-yes.txt'
    content = 'dunkeld tay beat'
    command(true, write_command(there_yes, content))
    command(true, append_command(there_yes, content.reverse))
    command(content+content.reverse, read_command(there_yes))
    result = saver.batch_assert(@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '417', %w(
  batch_assert() raises
  when any command is not true
  and subsequent commands are not executed
  ) do
    dirname = 'batch/e3/t4/17'
    command(true, create_command(dirname))
    command(true, exists_command(dirname))
    there_yes = dirname + '/there-yes.txt'
    content = 'monaltrie dee beat'
    command(true, write_command(there_yes, content))
    there_no = dirname + '/there-not.txt'
    command(false, read_command(there_no))
    command(true, append_command(there_yes, content.reverse))
    error = assert_raises(RuntimeError) {
      saver.batch_assert(@commands)
    }
    assert_equal "commands[3] != true", error.message
    assert_equal content, saver.read(there_yes), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_run_until_false
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '512', %w(
  batch_run_until_false()
  completes all its commands
  when nothing returns false
  ) do
    dirname = 'batch-run-until-false/x3/t5/12'
    command(true, create_command(dirname))
    command(true, exists_command(dirname))
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'newtyle tay beat'
    command(true, write_command(filename, content))
    command(true, append_command(filename, '1'))
    command(content+'1', read_command(filename))
    assert_batch_run_until_false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '513', %w(
  batch_run_until_false()
  stops at exists?() returning false
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/13'
    command(true, create_command(dirname))
    command(true, exists_command(dirname))
    command(false, exists_command(dirname+'X'))
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'dalmarnock tay beat'
    not_run(write_command(filename, content))
    assert_batch_run_until_false
    assert saver.exists?(dirname)
    refute saver.exists?(dirname+'X'), :does_not_execute_subsequent_commands
    refute saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '514', %w(
  batch_run_until_false()
  stops at create() returning false
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/14'
    command(true, create_command(dirname))
    command(false, create_command(dirname))
    filename = dirname + '/stops-at-exists.txt'
    content = 'stenton tay beat'
    not_run(write_command(filename, content))
    assert_batch_run_until_false
    assert saver.exists?(dirname)
    refute saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '515', %w(
  batch_run_until_false()
  stops at write() already existing file
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/15'
    command(true, create_command(dirname))
    filename = dirname + '/stops-at-write-false.txt'
    content = 'murthly tay beat'
    command(true, write_command(filename, content))
    command(false, write_command(filename, content))
    not_run(append_command(filename, 'extra'))
    assert_batch_run_until_false
    assert saver.exists?(dirname)
    assert_equal content, saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '516', %w(
  batch_run_until_false()
  stops at append() to non-existant file
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/16'
    command(true, create_command(dirname))
    filename = dirname + '/stops-at-append-false.txt'
    content = 'park dee beat'
    command(true, write_command(filename, content))
    command(true, append_command(filename, '1'))
    command(true, append_command(filename, '2'))
    command(false, append_command(filename+'X', '3'))
    not_run(append_command(filename, '4'))
    assert_batch_run_until_false
    assert saver.exists?(dirname)
    assert_equal content+'12', saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '517', %w(
  batch_run_until_false()
  stops at read() non-existent file
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/17'
    command(true, create_command(dirname))
    filename = dirname + '/stops-at-read-false.txt'
    content = 'inchmarlo dee beat'
    command(true, write_command(filename, content))
    command(false, read_command(filename+'X'))
    not_run(append_command(filename, 'extra'))
    assert_batch_run_until_false
    assert_equal content, saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_true
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '712', %w(
  batch_run_until_true()
  completes all its commands
  when nothing returns true
  ) do
    dirname = 'batch-run-until-true/x3/t7/12'
    filename = dirname + '/read-false.txt'
    command(false, read_command(filename+'1'))
    command(false, read_command(filename+'2'))
    command(false, read_command(filename+'3'))
    command(false, read_command(filename+'4'))
    command(false, read_command(filename+'5'))
    assert_batch_run_until_true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '713', %w(
  batch_run_until_true()
  stops at exists?() returning true
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/13'
    assert saver.create(dirname)
    command(false, exists_command(dirname+'1'))
    command(false, exists_command(dirname+'2'))
    command(false, exists_command(dirname+'3'))
    command(true,  exists_command(dirname))
    filename = dirname + '/stops-at-exists-true'
    not_run(write_command(filename, 'xxx'))
    assert_batch_run_until_true
    refute saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '714', %w(
  batch_run_until_true()
  stops at create() returning true
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/14'
    assert saver.create(dirname)
    command(false, create_command(dirname))
    command(false, create_command(dirname))
    command(false, create_command(dirname))
    command(true,  create_command(dirname+'1'))
    filename = dirname + '1/stops-at-create-true'
    not_run(write_command(filename, 'xxx'))
    assert_batch_run_until_true
    assert saver.exists?(dirname+'1'), :does_not_execute_subsequent_commands
    refute saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '715', %w(
  batch_run_until_true()
  stops at write() returning true
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/15'
    filename = dirname + '/stop-at-write-true'
    content = 'xxxxxx'
    assert saver.create(dirname)
    assert saver.write(filename, content)

    command(false, write_command(filename, content))
    command(true, write_command(filename+'1', content))
    not_run(append_command(filename, 'to-the-end'))
    assert_batch_run_until_true
    assert_equal content, saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '716', %w(
  batch_run_until_true()
  stops at append() returning true
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/16'
    filename = dirname + '/stop-at-append-true'
    content = 'X'
    assert saver.create(dirname)
    assert saver.write(filename, content)

    command(false, append_command(filename+'1', content))
    command(true, append_command(filename, content))
    not_run(append_command(filename, 'to-the-end'))
    assert_batch_run_until_true
    assert_equal 'XX', saver.read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '717', %w(
  batch_run_until_true()
  stops at read() a file that exists
  and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/17'
    event_3 = dirname + '/3.event.json'
    content = '{"colour":"red"}'

    saver.batch_assert([
      ['create',dirname],
      ['write',event_3,content]
    ])

    command(false, write_command(dirname + '/3.event.json', '{"colour":"amber"}'))
    command(false, read_command(dirname + '/0.event.json'))
    command(false, read_command(dirname + '/1.event.json'))
    command(false, read_command(dirname + '/2.event.json'))
    command(content, read_command(dirname + '/3.event.json'))
    not_run(write_command(dirname + '/4.event.json', '{"colour":"green"}'))

    assert_batch_run_until_true
    refute saver.read(dirname + '/4.event.json'), :does_not_execute_subsequent_commands
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

  def not_run(cmd)
    @commands << cmd
  end

  def assert_batch_run_until_false
    result = saver.batch_run_until_false(@commands)
    assert_equal @expected, result
  end

  def assert_batch_run_until_true
    result = saver.batch_run_until_true(@commands)
    assert_equal @expected, result
  end

end
