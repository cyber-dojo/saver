# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverDeprecatedPrimitivesTest < TestBase

  def self.hex_prefix
    'AD4'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(), create()

  multi_test '431',
  'exists?(dirname) is false before create(dirname) and true after' do
    dirname = 'client/34/X7/a8'
    refute exists?(dirname)
    create(dirname)
    assert exists?(dirname)
  end

  multi_test '432',
  'create(dirname) succeeds once and then fails' do
    dirname = 'client/r5/X7/03'
    assert create(dirname)
    refute create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  multi_test '640', %w(
    write(filename) succeeds
    when its dir of filename exists and filename does not exist
  ) do
    dirname = 'client/32/Xg/9j'
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    create(dirname)
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  multi_test '641', %w(
    write(filename) fails
    when its dir of filename does not exist
  ) do
    dirname = 'client/5e/X4/Aa'
    filename = dirname + '/readme.md'
    # no create(dirname)
    refute write(filename, 'bonjour')
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '642', %w(
    write(filename,content) fails
    when filename already exists
  ) do
    dirname = 'client/73/Xf/69'
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    create(dirname)
    assert write(filename, first_content)
    refute write(filename, 'second-content')
    assert_equal first_content, read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  multi_test '840', %w(
    append(filename,content) returns true
    and appends to the end of filename
    when filename already exists
  ) do
    dirname = 'client/69/Xb/2B'
    filename = dirname + '/readme.md'
    content = 'helloooo'
    create(dirname)
    write(filename, content)
    more = 'some-more'
    assert append(filename, more)
    assert_equal content+more, read(filename)
  end

  multi_test '841', %w(
    append(filename,content) returns false and does nothing
    when its dir of filename does not already exist
  ) do
    dirname = 'client/96/X8/59'
    filename = dirname + '/readme.md'
    # no create(dirname)
    refute append(filename, 'greetings')
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '842', %w(
    append(filename,content) does nothing and returns false
    when dir of filenme exists and filename does not exist
  ) do
    dirname = 'client/96/X8/59'
    filename = dirname + '/hiker.h'
    create(dirname)
    # no write(filename, '...')
    refute append(filename, 'int main(void);')
    assert read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  multi_test '437',
  'read(filename) reads what a successful write(filename,content) writes' do
    dirname = 'client/FD/X4/38'
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    create(dirname)
    write(filename, content)
    assert_equal content, read(filename)
  end

  multi_test '438',
  'read() returns false given a non-existent file-name' do
    filename = 'client/1z/X3/e4/not-there.txt'
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '439',
  'read(filename) returns false given an existing dirname' do
    dirname = 'client/2f/Xk/3P'
    create(dirname)
    assert read(dirname).is_a?(FalseClass)
  end

  private

  def create(dirname)
    saver.create(dirname)
  end

  def exists?(dirname)
    saver.exists?(dirname)
  end

  def write(filename, content)
    saver.write(filename, content)
  end

  def append(filename, content)
    saver.append(filename, content)
  end

  def read(filename)
    saver.read(filename)
  end

end
