# frozen_string_literal: true
require_relative 'test_base'

class DiskAssertAllTest < TestBase

  def self.hex_prefix
    '21C'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '416',
  'assert_all() returns array of results when all commands are true' do
    dirname = 'server/assert-all/e3/t4/16'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    there_yes = dirname + '/there-yes.txt'
    content = 'dunkeld tay beat'
    command(true, file_create_command(there_yes, content))
    command(true, file_append_command(there_yes, content.reverse))
    command(content+content.reverse, file_read_command(there_yes))
    result = saver.assert_all(commands:@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '417', %w(
  assert_all() raises
  when any command is not true
  and subsequent commands are not executed
  ) do
    dirname = 'server/assert-all/e3/t4/17'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    there_yes = dirname + '/there-yes.txt'
    content = 'monaltrie dee beat'
    command(true, file_create_command(there_yes, content))
    there_no = dirname + '/there-not.txt'
    command(false, file_read_command(there_no))
    command(true, file_append_command(there_yes, content.reverse))
    error = assert_raises(RuntimeError) {
      saver.assert_all(commands:@commands)
    }
    assert_equal "commands[3] != true", error.message
    assert_equal content, saver.run(command:file_read_command(there_yes)), :does_not_execute_subsequent_commands
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

end
