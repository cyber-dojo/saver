# frozen_string_literal: true
require_relative 'test_base'

class DiskRunTest < TestBase

  def self.hex_prefix
    'FA3'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # dir_exists?() dir_make()

  disk_tests '601',
  'dir_exists?(k) is false before dir_make(k) and true after' do
    dirname = 'groups/34/f6/01'
    refute disk.run(command:dir_exists_command(dirname))
    disk.run(command:dir_make_command(dirname))
    assert disk.run(command:dir_exists_command(dirname))
  end

  disk_tests '602',
  'dir_make succeeds once and then fails' do
    dirname = 'groups/r5/s6/02'
    assert disk.run(command:dir_make_command(dirname))
    refute disk.run(command:dir_make_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_create()

  disk_tests '603', %w(
    file_create() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'groups/32/f6/03'
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    disk.run(command:dir_make_command(dirname))
    assert disk.run(command:file_create_command(filename, content))
    assert_equal content, disk.run(command:file_read_command(filename))
  end

  disk_tests '604', %w(
    file_create() fails
    when its dir-name does not already exist
  ) do
    dirname = 'groups/5e/96/04'
    filename = dirname + '/readme.md'
    # disk.run(saver.dir_make_command(dirname) NOT RUN
    refute disk.run(command:file_create_command(filename, 'bonjour'))
    assert disk.run(command:file_read_command(filename)).is_a?(FalseClass)
  end

  disk_tests '605', %w(
    file_create() fails
    when its file-name already exists
  ) do
    dirname = 'groups/73/F6/05'
    filename = dirname + '/readme.md'
    content = 'greetings'
    disk.run(command:dir_make_command(dirname))
    assert disk.run(command:file_create_command(filename, content))
    refute disk.run(command:file_create_command(filename, 'appended-content'))
    assert_equal content, disk.run(command:file_read_command(filename))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_append()

  disk_tests '606', %w(
    file_append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'groups/69/16/06'
    filename = dirname + '/readme.md'
    content = 'helloooo'
    disk.run(command:dir_make_command(dirname))
    disk.run(command:file_create_command(filename, content))
    more = 'some-more'
    assert disk.run(command:file_append_command(filename, more))
    assert_equal content+more, disk.run(command:file_read_command(filename))
  end

  disk_tests '607', %w(
    file_append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'groups/96/16/07'
    filename = dirname + '/readme.md'
    # disk.run(saver.dir_make_command(dirname)) NOT RUN
    assert disk.run(command:file_append_command(filename, 'greetings')).is_a?(FalseClass)
    assert disk.run(command:file_read_command(filename)).is_a?(FalseClass)
  end

  disk_tests '608', %w(
    file_append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'groups/96/16/08'
    filename = dirname + '/hiker.h'
    disk.run(command:dir_make_command(dirname))
    # disk.run(file_create_command(filename, '...')) NOT RUN
    assert disk.run(command:file_append_command(filename, 'main')).is_a?(FalseClass)
    assert disk.run(command:file_read_command(filename)).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # file_read()

  disk_tests '609',
  'file_read() gives back what a successful file_create() accepts' do
    dirname = 'groups/FD/F6/09'
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    disk.run(command:dir_make_command(dirname))
    disk.run(command:file_create_command(filename, content))
    assert_equal content, disk.run(command:file_read_command(filename))
  end

  disk_tests '610',
  'file_read() returns false given a non-existent file-name' do
    filename = 'groups/1z/26/10/not-there.txt'
    assert disk.run(command:file_read_command(filename)).is_a?(FalseClass)
  end

  disk_tests '611',
  'file_read() returns false given an existing dir-name' do
    dirname = 'groups/2f/76/11'
    disk.run(command:dir_make_command(dirname))
    assert disk.run(command:file_read_command(dirname)).is_a?(FalseClass)
  end

end
