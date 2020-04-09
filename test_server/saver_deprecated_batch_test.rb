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
    command(true, ['create',dirname])
    command(true, ['exists?',dirname])
    there_no = dirname + '/there-not.txt'
    command(false, ['read',there_no])
    there_yes = dirname + '/there-yes.txt'
    content = 'tulchan spey beat'
    command(true, ['write',there_yes, content])
    command(true, ['append',there_yes, content.reverse])
    command(content+content.reverse, ['read',there_yes])
    command(false, ['read',there_no])
    result = saver.batch(@commands)
    assert_equal @expected, result
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

end
