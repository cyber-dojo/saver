# frozen_string_literal: true
require_relative 'test_base'

class SaverRunTest < TestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # dir_exists?()

  test '431', %w(
  |dir_exists?(dirname) is false
  |when dirname does not exist as a dir
  |and dirname does not exist as a file
  ) do
    dirname = 'client/34/f7/a8'
    refute dir_exists?(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '432', %w(
  |dir_exists?(dirname) is true
  |after dir_make(dirname)
  ) do
    dirname = 'client/34/f7/a9'
    dir_make(dirname)
    assert dir_exists?(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '433', %w(
  |dir_exists?(dirname) is false
  |when dirname is an existing filename
  ) do
    dirname = 'client/r5/s7/04'
    filename = dirname + '/' + 'readme.txt'
    content = 'hello world'
    dir_make(dirname)
    file_create(filename, content)
    refute dir_exists?(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '434', %w(
  |dir_exists?(dirname) raises
  |when dirname is not a String
  ) do
    dirname = [2]
    message = 'malformed:command:dir_exists?(dirname!=String):'
    assert_raises_SaverException(message,'dir_exists?',dirname) {
      dir_exists?(dirname)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # dir_make()

  test '5E0', %w(
  |dir_make(dirname) is true
  |when dirname is a String
  |and dirname does not exist as a dir
  |and dirname does not exist as a file
  ) do
    dirname = 'client/r5/sE/34'
    assert dir_make(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5E1', %w(
  |dir_make(dirname) is false
  |when dirname is a String
  |and a dir with that name exists
  ) do
    dirname = 'client/r5/sE/35'
    assert dir_make(dirname)
    refute dir_make(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5E2', %w(
  |dir_make(dirname) is false
  |when dirname is a String
  |and a file with that name exists
  ) do
    dirname = 'client/r5/s5/E2'
    filename = dirname + '/' + 'manifest.json'
    content = '{"display_name":"Java, JUnit"}'
    assert dir_make(dirname)
    file_create(filename, content)
    refute dir_make(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5E3', %w(
  |dir_make(dirname) raises
  |when dirname is not a String
  ) do
    dirname = {"a"=>42}
    message = 'malformed:command:dir_make(dirname!=String):'
    assert_raises_SaverException(message,'dir_make',dirname) {
      dir_make(dirname)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_create()

  test '640', %w(
  |file_create(filename,content) is true
  |when its dir exists
  |and its file does not exist
  ) do
    dirname = 'client/32/fg/9j'
    filename = dirname + '/' + 'events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    dir_make(dirname)
    assert file_create(filename, content)
    assert_equal content, file_read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '641', %w(
  |file_create(filename,content) is false
  |when its dir does not already exist
  ) do
    dirname = 'client/5e/94/Aa'
    filename = dirname + '/readme.md'
    # no create(dirname)
    refute file_create(filename, 'bonjour')
    assert file_read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '642', %w(
  |file_create(filename,content) is false
  |when filename already exists
  ) do
    dirname = 'client/73/Ff/69'
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    dir_make(dirname)
    assert file_create(filename, first_content)
    refute file_create(filename, 'second-content')
    assert_equal first_content, file_read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '643', %w(
  |file_create(filename,content) is false
  |when filename is a dir
  ) do
    dirname = 'client/43/Ff/69'
    content = 'greetings'
    dir_make(dirname)
    refute file_create(dirname, content)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '644', %w(
  |file_create(filename,content) raises
  |when filename is a not a String
  ) do
    filename = nil
    content = 'greetings'
    message = 'malformed:command:file_create(filename!=String):'
    assert_raises_SaverException(message,'file_create',filename,content) {
      file_create(filename, content)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '645', %w(
  |file_create(filename,content) raises
  |when content is a not a String
  ) do
    dirname = 'client/44/qR/6P'
    filename = dirname + '/' + 'manifest.json'
    content = 4.5
    message = 'malformed:command:file_create(content!=String):'
    assert_raises_SaverException(message,'file_create',filename,content) {
      file_create(filename, content)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_append()

  test '840', %w(
  |file_append(filename,content) returns true
  |and appends to the end of filename
  |when filename is a String and already exists as a file
  |and content is a String
  ) do
    dirname = 'client/69/1b/2B'
    filename = dirname + '/readme.md'
    content = 'helloooo'
    dir_make(dirname)
    file_create(filename, content)
    more = 'some-more'
    assert file_append(filename, more)
    assert_equal content+more, file_read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '841', %w(
  |file_append(filename,content) returns false
  |and does nothing
  |when filename already exists as a dir
  ) do
    dirname = 'client/69/1b/2C'
    content = 'helloooo'
    dir_make(dirname)
    refute file_append(dirname, content)
    refute file_read(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '842', %w(
  |file_append(filename,content) returns false
  |and does nothing
  |when its dir does not already exist
  ) do
    dirname = 'client/96/18/59'
    filename = dirname + '/readme.md'
    # no create(dirname)
    refute file_append(filename, 'greetings')
    assert file_read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '843', %w(
  |file_append(filename,content) does nothing
  |and returns false
  |when its dir exists and its file does not exist
  ) do
    dirname = 'client/96/18/59'
    filename = dirname + '/hiker.h'
    dir_make(dirname)
    # no file_create(filename, '...')
    refute file_append(filename, 'int main(void);')
    assert file_read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '844', %w(
  |file_append(filename,content) raises
  |when filename is not a String
  ) do
    filename = false
    content = 'wibble'
    message = 'malformed:command:file_append(filename!=String):'
    assert_raises_SaverException(message,'file_append',filename,content) {
      file_append(filename,content)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '845', %w(
  |file_append(filename,content) raises
  |when content is not a String
  ) do
    filename = 'wibble.txt'
    content = false
    message = 'malformed:command:file_append(content!=String):'
    assert_raises_SaverException(message,'file_append',filename,content) {
      file_append(filename,content)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_read()

  test '437', %w(
  |file_read(filename) reads what a successful write(filename,content) writes
  ) do
    dirname = 'client/FD/F4/38'
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    dir_make(dirname)
    file_create(filename, content)
    assert_equal content, file_read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438', %w(
  |file_read(filename) returns false
  |when filename is a String that does not exist as a file
  ) do
    filename = 'client/1z/23/e4/not-there.txt'
    assert file_read(filename).is_a?(FalseClass)
  end

  test '439', %w(
  |file_read(filename) returns false
  |when filename is a String that exists as a dir
  ) do
    dirname = 'client/2f/7k/3P'
    dir_make(dirname)
    assert file_read(dirname).is_a?(FalseClass)
  end

  private

  def dir_make(dirname)
    saver.run(dir_make_command(dirname))
  end

  def dir_exists?(dirname)
    saver.run(dir_exists_command(dirname))
  end

  def file_create(filename, content)
    saver.run(file_create_command(filename, content))
  end

  def file_append(filename, content)
    saver.run(file_append_command(filename, content))
  end

  def file_read(filename)
    saver.run(file_read_command(filename))
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_raises_SaverException(message, *command)
    assert_raises(::HttpJsonHash::ServiceError) { yield }
  end

end
