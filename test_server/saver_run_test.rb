# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/saver'

class SaverRunTest < TestBase

  def self.hex_prefix
    'FA3'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # dir_exists? dir_make

  test '601',
  'dir_exists?(k) is false before dir_make(k) and true after' do
    dirname = 'groups/34/f6/01'
    refute saver.run(dir_exists_command(dirname))
    saver.run(dir_make_command(dirname))
    assert saver.run(dir_exists_command(dirname))
  end

  test '602',
  'dir_make succeeds once and then fails' do
    dirname = 'groups/r5/s6/02'
    assert saver.run(dir_make_command(dirname))
    refute saver.run(dir_make_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_create()

  test '603', %w(
    file_create() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'groups/32/f6/03'
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    saver.run(dir_make_command(dirname))
    assert saver.run(file_create_command(filename, content))
    assert_equal content, saver.read(filename)
  end

  test '604', %w(
    file_create() fails
    when its dir-name does not already exist
  ) do
    dirname = 'groups/5e/96/04'
    filename = dirname + '/readme.md'
    # no saver.run(saver.dir_make_command(dirname)
    refute saver.run(file_create_command(filename, 'bonjour'))
    assert saver.run(file_read_command(filename)).is_a?(FalseClass)
  end

  test '605', %w(
    file_create() fails
    when its file-name already exists
  ) do
    dirname = 'groups/73/F6/05'
    filename = dirname + '/readme.md'
    content = 'greetings'
    saver.run(dir_make_command(dirname))
    assert saver.run(file_create_command(filename, content))
    refute saver.run(file_create_command(filename, 'appended-content'))
    assert_equal content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_append()

  test '606', %w(
    file_append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'groups/69/16/06'
    filename = dirname + '/readme.md'
    content = 'helloooo'
    saver.run(dir_make_command(dirname))
    saver.run(file_create_command(filename, content))
    more = 'some-more'
    assert saver.run(file_append_command(filename, more))
    assert_equal content+more, saver.read(filename)
  end

  test '607', %w(
    file_append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'groups/96/16/07'
    filename = dirname + '/readme.md'
    # no saver.run(saver.dir_make_command(dirname))
    assert saver.run(file_append_command(filename, 'greetings')).is_a?(FalseClass)
    assert saver.run(file_read_command(filename)).is_a?(FalseClass)
  end

  test '608', %w(
    file_append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'groups/96/16/08'
    filename = dirname + '/hiker.h'
    saver.run(dir_make_command(dirname))
    # no saver.run(saver.file_create_command(filename, '...'))
    assert saver.run(file_append_command(filename, 'main')).is_a?(FalseClass)
    assert saver.run(file_read_command(filename)).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_read()

  test '609',
  'file_read() gives back what a successful file_create() accepts' do
    dirname = 'groups/FD/F6/09'
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    saver.run(dir_make_command(dirname))
    saver.run(file_create_command(filename, content))
    assert_equal content, saver.read(filename)
  end

  test '610',
  'file_read() returns false given a non-existent file-name' do
    filename = 'groups/1z/26/10/not-there.txt'
    assert saver.run(file_read_command(filename)).is_a?(FalseClass)
  end

  test '611',
  'file_read() returns false given an existing dir-name' do
    dirname = 'groups/2f/76/11'
    saver.run(dir_make_command(dirname))
    assert saver.run(file_read_command(dirname)).is_a?(FalseClass)
  end

end
