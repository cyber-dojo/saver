
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverRunTest < TestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()

  multi_test '431', %w(
  |exists?(dirname) is false
  |before create(dirname)
  ) do
    dirname = 'client/34/f7/a8'
    refute exists?(dirname)
    assert create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '432', %w(
  |exists?(dirname) is true
  |after create(dirname)
  ) do
    dirname = 'client/34/f7/a9'
    assert create(dirname)
    assert exists?(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '433', %w(
  |exists?(dirname) is false
  |when dirname is an existing filename
  ) do
    dirname = 'client/r5/s7/04'
    assert create(dirname)
    filename = dirname + '/' + 'readme.txt'
    content = 'hello world'
    assert write(filename, content)
    refute exists?(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '434', %w(
  |exists?(dirname) raises
  |when dirname is not a String
  ) do
    dirname = [2]
    error = assert_raises(SaverException) { exists?(dirname) }
    json = JSON.parse!(error.message)
    assert_equal '/run', json['path'], :path
    expected_body = { 'command'=>[ 'exists?',dirname ] }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal 'malformed:command:exists?-1!String (Array):', json['message'], :message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # create()

  multi_test '5E0', %w(
  |create(dirname) returns true the first time
  ) do
    dirname = 'client/r5/sE/34'
    assert create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '5E1', %w(
  |create(dirname) returns false the second time
  ) do
    dirname = 'client/r5/sE/35'
    assert create(dirname)
    refute create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  multi_test '640', %w(
  |write(filename,content) succeeds
  |when its dir exists
  |and its file does not exist
  ) do
    dirname = 'client/32/fg/9j'
    assert create(dirname)
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '641', %w(
  |write(filename,content) fails
  |when its dir does not already exist
  ) do
    dirname = 'client/5e/94/Aa'
    # no create(dirname)
    filename = dirname + '/readme.md'
    refute write(filename, 'bonjour')
    assert read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '642', %w(
  |write(filename,content) fails
  |when filename already exists
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
  # append()

  multi_test '840', %w(
  |append(filename,content) returns true
  |and appends to the end of filename
  |when filename already exists as a file
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

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '841', %w(
  |append(filename,content) returns false
  |and does nothing
  |when filename already exists as a dir
  ) do
    dirname = 'client/69/1b/2C'
    assert create(dirname)
    content = 'helloooo'
    refute append(dirname, content)
    refute read(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '842', %w(
  |append(filename,content) returns false
  |and does nothing
  |when its dir does not already exist
  ) do
    dirname = 'client/96/18/59'
    # no create(dirname)
    filename = dirname + '/readme.md'
    refute append(filename, 'greetings')
    assert read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '843', %w(
  |append(filename,content) does nothing
  |and returns false
  |when its dir exists and its file does not exist
  ) do
    dirname = 'client/96/18/59'
    assert create(dirname)
    filename = dirname + '/hiker.h'
    # no write(filename, '...')
    refute append(filename, 'int main(void);')
    assert read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  multi_test '437', %w(
  |read(filename) reads what a successful write(filename,content) writes
  ) do
    dirname = 'client/FD/F4/38'
    assert create(dirname)
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '438', %w(
  |read(filename) returns false given a non-existent filename
  ) do
    filename = 'client/1z/23/e4/not-there.txt'
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '439', %w(
  |read(filename) returns false given an existing dirname
  ) do
    dirname = 'client/2f/7k/3P'
    create(dirname)
    assert read(dirname).is_a?(FalseClass)
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
