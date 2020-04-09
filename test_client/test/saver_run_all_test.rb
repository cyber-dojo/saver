
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverRunAllTest < TestBase

  def self.hex_prefix
    '86A'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_all()

  multi_test '514',
  'run_all() batches exists/create/write/append/read commands' do
    expected = []
    commands = []

    dirname = 'client/e3/t6/A8'
    commands << dir_make_command(dirname)
    expected << true
    commands << dir_exists_command(dirname)
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << file_create_command(there_yes,content)
    expected << true
    commands << file_append_command(there_yes,content.reverse)
    expected << true

    there_not = dirname + '/there-not.txt'
    commands << file_append_command(there_not,'nope')
    expected << false

    commands << file_read_command(there_yes)
    expected << content+content.reverse

    commands << file_read_command(there_not)
    expected << false

    result = saver.run_all(commands)
    assert_equal expected, result
  end

  private

  def dir_make_command(dirname)
    saver.dir_make_command(dirname)
  end

  def dir_exists_command(dirname)
    saver.dir_exists_command(dirname)
  end

  def file_create_command(filename, content)
    saver.file_create_command(filename, content)
  end

  def file_append_command(filename, content)
    saver.file_append_command(filename, content)
  end

  def file_read_command(filename)
    saver.file_read_command(filename)
  end

end
