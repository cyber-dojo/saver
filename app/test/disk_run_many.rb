# frozen_string_literal: true
require_relative 'test_base'

class DiskRunManyTest < TestBase

  def self.id58_prefix
    '34F'
  end

  def id58_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_all()
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '314', %w(
  |run_all() runs all its commands
  |not stopping when any return false
  ) do
    dirname = 'batch/e3/t3/14'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    there_no = dirname + '/there-not.txt'
    command(false, file_read_command(there_no))
    there_yes = dirname + '/there-yes.txt'
    content = 'tulchan spey beat'
    command(true, file_create_command(there_yes, content))
    command(true, file_append_command(there_yes, content.reverse))
    command(content+content.reverse, file_read_command(there_yes))
    command(false, file_read_command(there_no))
    result = disk.run_all(commands:@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_until_false()
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '512', %w(
  |run_until_false()
  |completes all its commands
  |when nothing returns false
  ) do
    dirname = 'batch-run-until-false/x3/t5/12'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'newtyle tay beat'
    command(true, file_create_command(filename, content))
    command(true, file_append_command(filename, '1'))
    command(content+'1', file_read_command(filename))
    assert_run_until_false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '513', %w(
  |run_until_false()
  |stops at exists?() returning false
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/13'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    command(false, dir_exists_command(dirname+'X'))
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'dalmarnock tay beat'
    not_run(file_create_command(filename, content))
    assert_run_until_false
    assert dir_exists?(dirname)
    refute dir_exists?(dirname+'X'), :does_not_execute_subsequent_commands
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '514', %w(
  |run_until_false()
  |stops at create() returning false
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/14'
    command(true, dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    filename = dirname + '/stops-at-exists.txt'
    content = 'stenton tay beat'
    not_run(file_create_command(filename, content))
    assert_run_until_false
    assert dir_exists?(dirname)
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '515', %w(
  |run_until_false()
  |stops at write() already existing file
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/15'
    command(true, dir_make_command(dirname))
    filename = dirname + '/stops-at-write-false.txt'
    content = 'murthly tay beat'
    command(true, file_create_command(filename, content))
    command(false, file_create_command(filename, content))
    not_run(file_append_command(filename, 'extra'))
    assert_run_until_false
    assert dir_exists?(dirname)
    assert_equal content, file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '516', %w(
  |run_until_false()
  |stops at append() to non-existant file
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/16'
    command(true, dir_make_command(dirname))
    filename = dirname + '/stops-at-append-false.txt'
    content = 'park dee beat'
    command(true, file_create_command(filename, content))
    command(true, file_append_command(filename, '1'))
    command(true, file_append_command(filename, '2'))
    command(false, file_append_command(filename+'X', '3'))
    not_run(file_append_command(filename, '4'))
    assert_run_until_false
    assert dir_exists?(dirname)
    assert_equal content+'12', file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '517', %w(
  |run_until_false()
  |stops at read() non-existent file
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-false/x3/t5/17'
    command(true, dir_make_command(dirname))
    filename = dirname + '/stops-at-read-false.txt'
    content = 'inchmarlo dee beat'
    command(true, file_create_command(filename, content))
    command(false, file_read_command(filename+'X'))
    not_run(file_append_command(filename, 'extra'))
    assert_run_until_false
    assert_equal content, file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_until_true()
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '712', %w(
  |run_until_true()
  |completes all its commands
  |when nothing returns true
  ) do
    dirname = 'batch-run-until-true/x3/t7/12'
    filename = dirname + '/read-false.txt'
    command(false, file_read_command(filename+'1'))
    command(false, file_read_command(filename+'2'))
    command(false, file_read_command(filename+'3'))
    command(false, file_read_command(filename+'4'))
    command(false, file_read_command(filename+'5'))
    assert_run_until_true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '713', %w(
  |run_until_true()
  |stops at exists?() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/13'
    disk.assert(command:dir_make_command(dirname))

    command(false, dir_exists_command(dirname+'1'))
    command(false, dir_exists_command(dirname+'2'))
    command(false, dir_exists_command(dirname+'3'))
    command(true,  dir_exists_command(dirname))
    filename = dirname + '/stops-at-exists-true'
    not_run(file_create_command(filename, 'xxx'))
    assert_run_until_true
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '714', %w(
  |run_until_true()
  |stops at create() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/14'
    disk.assert(command:dir_make_command(dirname))

    command(false, dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    command(true,  dir_make_command(dirname+'1'))
    filename = dirname + '1/stops-at-create-true'
    not_run(file_create_command(filename, 'xxx'))
    assert_run_until_true
    assert dir_exists?(dirname+'1'), :does_not_execute_subsequent_commands
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '715', %w(
  |run_until_true()
  |stops at write() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/15'
    filename = dirname + '/stop-at-write-true'
    content = 'xxxxxx'
    disk.assert_all(commands:[
      dir_make_command(dirname),
      file_create_command(filename, content)
    ])

    command(false, file_create_command(filename, content))
    command(true, file_create_command(filename+'1', content))
    not_run(file_append_command(filename, 'to-the-end'))
    assert_run_until_true
    assert_equal content, file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '716', %w(
  |run_until_true()
  |stops at append() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/16'
    filename = dirname + '/stop-at-append-true'
    content = 'X'

    disk.assert_all(commands:[
      dir_make_command(dirname),
      file_create_command(filename, content)
    ])

    command(false, file_append_command(filename+'1', content))
    command(true, file_append_command(filename, content))
    not_run(file_append_command(filename, 'to-the-end'))
    assert_run_until_true
    assert_equal 'XX', file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  disk_tests '717', %w(
  |run_until_true()
  |stops at read() a file that exists
  |and does not execute subsequent commands
  ) do
    dirname = 'batch-run-until-true/x3/t7/17'
    event_3 = dirname + '/3.event.json'
    content = '{"colour":"red"}'

    disk.assert_all(commands:[
      dir_make_command(dirname),
      file_create_command(event_3,content)
    ])

    command(false, file_create_command(dirname + '/3.event.json', '{"colour":"amber"}'))
    command(false, file_read_command(dirname + '/0.event.json'))
    command(false, file_read_command(dirname + '/1.event.json'))
    command(false, file_read_command(dirname + '/2.event.json'))
    command(content, file_read_command(dirname + '/3.event.json'))
    not_run(file_create_command(dirname + '/4.event.json', '{"colour":"green"}'))

    assert_run_until_true
    refute file_read(dirname + '/4.event.json'), :does_not_execute_subsequent_commands
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

  def not_run(cmd)
    @commands << cmd
  end

  # - - - - - - - - - - - - - - - - - - -

  def assert_run_until_false
    result = disk.run_until_false(commands:@commands)
    assert_equal @expected, result
  end

  def assert_run_until_true
    result = disk.run_until_true(commands:@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - -

  def dir_exists?(dirname)
    disk.run(command:dir_exists_command(dirname))
  end

  def file_read(filename)
    disk.run(command:file_read_command(filename))
  end

end
