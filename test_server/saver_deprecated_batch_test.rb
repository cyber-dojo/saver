require_relative 'test_base'
require_relative '../src/saver'

class SaverDeprecatedBatchTest < TestBase

  def self.hex_prefix
    '2E7'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch

  test '934', %w( support batch() till switched to run_all() ) do
    dirname = 'batch/e3/t9/34'
    command(true, old_dir_make_command(dirname))
    command(true, old_dir_exists_command(dirname))
    there_no = dirname + '/there-not.txt'
    command(false, old_file_read_command(there_no))
    there_yes = dirname + '/there-yes.txt'
    content = 'tulchan spey beat'
    command(true, old_file_create_command(there_yes, content))
    command(true, old_file_append_command(there_yes, content.reverse))
    command(content+content.reverse, old_file_read_command(there_yes))
    command(false, old_file_read_command(there_no))
    result = saver.batch(@commands)
    assert_equal @expected, result
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

  def old_dir_make_command(dirname)
    ['create',dirname]
  end

  def old_dir_exists_command(dirname)
    ['exists?',dirname]
  end

  def old_file_create_command(filename,content)
    ['write',filename,content]
  end

  def old_file_append_command(filename,content)
    ['append',filename,content]
  end

  def old_file_read_command(filename)
    ['read',filename]
  end

end
