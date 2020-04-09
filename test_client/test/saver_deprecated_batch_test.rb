
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverDeprecatedBatchTest < TestBase

  def self.hex_prefix
    '76A'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '5E4',
  'batch() runs old commands' do
    dirname = 'client/e3/76/A5'
    command(true, old_dir_make_command(dirname))

    command(true, old_dir_exists_command(dirname))

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    command(true, old_file_create_command(there_yes,content))
    command(true, old_file_append_command(there_yes,content.reverse))

    there_not = dirname + '/there-not.txt'
    command(false, old_file_append_command(there_not,'nope'))

    command(content+content.reverse, old_file_read_command(there_yes))

    command(false, old_file_read_command(there_not))

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
