
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverBatchTest < TestBase

  def self.hex_prefix
    '86A'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_run()

  multi_test '514',
  'batch_run() batches exists/create/write/append/read commands' do
    expected = []
    commands = []

    dirname = 'client/e3/t6/A8'
    commands << create_command(dirname)
    expected << true
    commands << exists_command(dirname)
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << write_command(there_yes,content)
    expected << true
    commands << append_command(there_yes,content.reverse)
    expected << true

    there_not = dirname + '/there-not.txt'
    commands << append_command(there_not,'nope')
    expected << false

    commands << read_command(there_yes)
    expected << content+content.reverse

    commands << read_command(there_not)
    expected << false

    result = saver.batch_run(commands)
    assert_equal expected, result
  end

  private

  def create_command(dirname)
    saver.create_command(dirname)
  end

  def exists_command(dirname)
    saver.exists_command(dirname)
  end

  def write_command(filename, content)
    saver.write_command(filename, content)
  end

  def append_command(filename, content)
    saver.append_command(filename, content)
  end

  def read_command(filename)
    saver.read_command(filename)
  end

end
