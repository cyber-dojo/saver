
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverTest < TestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  REAL_TEST_MARK = '<real>'
  FAKE_TEST_MARK = '<fake>'

  def self.multi_test(hex_suffix, *lines, &block)
    real_lines = [REAL_TEST_MARK] + lines
    test(hex_suffix+'0', *real_lines, &block)
    fake_lines = [FAKE_TEST_MARK] + lines
    test(hex_suffix+'1', *fake_lines, &block)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def saver
    if fake_test?
      @saver ||= SaverServiceFake.new
    else
      @saver ||= SaverService.new
    end
  end

  def fake_test?
    test_name.start_with?(FAKE_TEST_MARK)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha

  multi_test '190', %w( sha is sha of image's git commit ) do
    sha = saver.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready?

  multi_test '602',
  %w( ready? is always true ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # alive?

  multi_test '603',
  %w( alive? is always true ) do
    assert saver.alive?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : exists?(), create()

  multi_test '431',
  'exists?(dirname) is false before create(dirname) and true after' do
    dirname = 'client/34/f7/a8'
    refute exists?(dirname)
    assert create(dirname)
    assert exists?(dirname)
  end

  multi_test '432',
  'create(dirname) succeeds once and then fails' do
    dirname = 'client/r5/s7/03'
    assert create(dirname)
    refute create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : write()

  multi_test '640', %w(
    write(filename) succeeds
    when its dir of filename exists and filename does not exist
  ) do
    dirname = 'client/32/fg/9j'
    assert create(dirname)
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  multi_test '641', %w(
    write(filename) fails
    when its dir of filename does not already exist
  ) do
    dirname = 'client/5e/94/Aa'
    # no create(dirname)
    filename = dirname + '/readme.md'
    refute write(filename, 'bonjour')
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '642', %w(
    write(filename,content) fails
    when filename already exists
  ) do
    dirname = 'client/73/Ff/69'
    assert create(dirname)
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert write(filename, first_content)
    refute write(filename, 'second-content')
    assert_equal first_content, read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : append()

  multi_test '840', %w(
    append(filename,content) returns true and appends to the end of filename
    when filename already exists
  ) do
    dirname = 'client/69/1b/2B'
    assert create(dirname)
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert write(filename, content)
    more = 'some-more'
    assert append(filename, more)
    assert_equal content+more, read(filename)
  end

  multi_test '841', %w(
    append(filename,content) returns false and does nothing
    when its dir of filename does not already exist
  ) do
    dirname = 'client/96/18/59'
    # no create(dirname)
    filename = dirname + '/readme.md'
    refute append(filename, 'greetings')
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '842', %w(
    append(filename,content) does nothing and returns false
    when dir of filenme exists and filename does not exist
  ) do
    dirname = 'client/96/18/59'
    assert create(dirname)
    filename = dirname + '/hiker.h'
    # no write(filename, '...')
    refute append(filename, 'int main(void);')
    assert read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : read()

  multi_test '437',
  'read(filename) reads what a successful write(filename,content) writes' do
    dirname = 'client/FD/F4/38'
    assert create(dirname)
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  multi_test '438',
  'read() returns false given a non-existent file-name' do
    filename = 'client/1z/23/e4/not-there.txt'
    assert saver.run(saver.read_command(filename)).is_a?(FalseClass)
  end

  multi_test '439',
  'read(filename) returns false given an existing dirname' do
    dirname = 'client/2f/7k/3P'
    create(dirname)
    assert read(dirname).is_a?(FalseClass)
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

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: <real> and <fake> fail "identically"...

  test '514', %w(
    <real> create with non-string argument raises SaverException
  ) do
    error = assert_raises(SaverException) { create(42) }
    json = JSON.parse(error.message)
    assert_equal '/run', json['path']
    assert_equal 'SaverService', json['class']
    assert_equal 'malformed:command:create-1!String (Integer):', json['message']
  end

  private

  def create(dirname)
    saver.run(create_command(dirname))
  end

  def exists?(dirname)
    saver.run(exists_command(dirname))
  end

  def write(filename, content)
    saver.run(write_command(filename, content))
  end

  def append(filename, content)
    saver.run(append_command(filename, content))
  end

  def read(filename)
    saver.run(read_command(filename))
  end

  # - - - - - - - - - - - - - - - - - - - -

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
