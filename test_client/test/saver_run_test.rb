
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
    assert_equal 'malformed:command:exists?(key!=String):', json['message'], :message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # create()

  multi_test '5E0', %w(
  |create(dirname) is true
  |when dirname is a String
  |and a dir with that name does not exist
  ) do
    dirname = 'client/r5/sE/34'
    assert create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '5E1', %w(
  |create(dirname) is false
  |when dirname is a String
  |and a dir with that name exists
  ) do
    dirname = 'client/r5/sE/35'
    assert create(dirname)
    refute create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '5E2', %w(
  |create(dirname) is false
  |when dirname is a String
  |and a file with that name exists
  ) do
    dirname = 'client/r5/s5/E2'
    assert create(dirname)
    filename = dirname + '/' + 'manifest.json'
    content = '{"display_name":"Java, JUnit"}'
    assert write(filename, content)
    refute create(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '5E3', %w(
  |create(dirname) raises
  |when dirname is not a String
  ) do
    dirname = {"a"=>42}
    error = assert_raises(SaverException) { create(dirname) }
    json = JSON.parse!(error.message)
    assert_equal '/run', json['path'], :path
    expected_body = { 'command'=>[ 'create',dirname ] }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal 'malformed:command:create(key!=String):', json['message'], :message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  multi_test '640', %w(
  |write(filename,content) is true
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
  |write(filename,content) is false
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
  |write(filename,content) is false
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

  multi_test '643', %w(
  |write(filename,content) is false
  |when filename is a dir
  ) do
    dirname = 'client/43/Ff/69'
    assert create(dirname)
    content = 'greetings'
    refute write(dirname, content)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '644', %w(
  |write(filename,content) raises
  |when filename is a not a String
  ) do
    dirname = 'client/qZ/Ff/69'
    assert create(dirname)
    filename = nil
    content = 'greetings'
    error = assert_raises(SaverException) { write(filename, content) }
    json = JSON.parse!(error.message)
    assert_equal '/run', json['path'], :path
    expected_body = { 'command'=>[ 'write',filename,content ] }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal 'malformed:command:write(key!=String):', json['message'], :message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '645', %w(
  |write(filename,content) raises
  |when content is a not a String
  ) do
    dirname = 'client/44/Ff/69'
    assert create(dirname)
    filename = dirname + '/' + 'manifest.json'
    content = 4.5
    error = assert_raises(SaverException) { write(filename, content) }
    json = JSON.parse!(error.message)
    assert_equal '/run', json['path'], :path
    expected_body = { 'command'=>[ 'write',filename,content ] }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal 'malformed:command:write(value!=String):', json['message'], :message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  multi_test '840', %w(
  |append(filename,content) returns true
  |and appends to the end of filename
  |when filename is a String and already exists as a file
  |and content is a String
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

  multi_test '844', %w(
  |append(filename,content) raises
  |when filename is not a String
  ) do
    filename = false
    content = 'wibble'
    error = assert_raises(SaverException) { append(filename,content) }
    json = JSON.parse!(error.message)
    assert_equal '/run', json['path'], :path
    expected_body = { 'command'=>[ 'append',filename,content ] }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal 'malformed:command:append(key!=String):', json['message'], :message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '845', %w(
  |append(filename,content) raises
  |when content is not a String
  ) do
    filename = 'wibble.txt'
    content = false
    error = assert_raises(SaverException) { append(filename,content) }
    json = JSON.parse!(error.message)
    assert_equal '/run', json['path'], :path
    expected_body = { 'command'=>[ 'append',filename,content ] }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal 'malformed:command:append(value!=String):', json['message'], :message
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
