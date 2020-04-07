require_relative 'test_base'
require_relative '../src/saver'

class SaverPrimitivesTest < TestBase

  def self.hex_prefix
    'FA4'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(), create()

  test '431',
  'exists?(k) is false before create(k) and true after' do
    dirname = 'groups/34/f7/a8'
    refute saver.exists?(dirname)
    assert saver.create(dirname)
    assert saver.exists?(dirname)
  end

  test '432',
  'create succeeds once and then fails' do
    dirname = 'groups/r5/s7/03'
    assert saver.create(dirname)
    refute saver.create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  test '640', %w(
    write() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'groups/32/fg/9j'
    assert saver.create(dirname)
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '641', %w(
    write() fails
    when its dir-name does not already exist
  ) do
    dirname = 'groups/5e/94/Aa'
    # no saver.create(dirname)
    filename = dirname + '/readme.md'
    refute saver.write(filename, 'bonjour')
    assert saver.read(filename).is_a?(FalseClass)
  end

  test '642', %w(
    write() fails
    when its file-name already exists
  ) do
    dirname = 'groups/73/Ff/69'
    assert saver.create(dirname)
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert saver.write(filename, first_content)
    refute saver.write(filename, 'second-content')
    assert_equal first_content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  test '840', %w(
    append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'groups/69/1b/2B'
    assert saver.create(dirname)
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert saver.write(filename, content)
    more = 'some-more'
    assert saver.append(filename, more)
    assert_equal content+more, saver.read(filename)
  end

  test '841', %w(
    append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'groups/96/18/59'
    # saver.create(dirname) # say this was missed
    filename = dirname + '/readme.md'
    refute saver.append(filename, 'greetings')
    assert saver.read(filename).is_a?(FalseClass)
  end

  test '842', %w(
    append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'groups/96/18/59'
    assert saver.create(dirname)
    filename = dirname + '/hiker.h'
    # saver.write(filename, '...') # say this was missed
    refute saver.append(filename, 'int main(void);')
    assert saver.read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  test '437',
  'read() gives back what a successful write() accepts' do
    dirname = 'groups/FD/F4/38'
    assert saver.create(dirname)
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '438',
  'read() returns false given a non-existent file-name' do
    filename = 'groups/1z/23/e4/not-there.txt'
    assert saver.read(filename).is_a?(FalseClass)
  end

  test '439',
  'read() returns false given an existing dir-name' do
    dirname = 'groups/2f/7k/3P'
    saver.create(dirname)
    assert saver.read(dirname).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # assert()

  test '538',
  'assert() raises when its command is not true' do
    dirname = 'groups/Fw/FP/3p'
    error = assert_raises(RuntimeError) {
      saver.assert(['exists?',dirname])
    }
    assert_equal 'command != true', error.message
    refute saver.exists?(dirname)
  end

  test '539',
  'assert() returns command result when command is true' do
    dirname = 'groups/sw/EP/7K'
    filename = dirname + '/' + '3.events.json'
    content = '{"colour":"red"}'
    saver.create(dirname)
    saver.write(filename, content)
    read = saver.assert(['read',filename])
    assert_equal content, read
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run() : exists? create

  test '601',
  'exists?(k) is false before create(k) and true after' do
    dirname = 'groups/34/f6/01'
    refute saver.run(exists_command(dirname))
    assert saver.run(create_command(dirname))
    assert saver.run(exists_command(dirname))
  end

  test '602',
  'create succeeds once and then fails' do
    dirname = 'groups/r5/s6/02'
    assert saver.run(create_command(dirname))
    refute saver.run(create_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : write()

  test '603', %w(
    write() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'groups/32/f6/03'
    assert saver.run(create_command(dirname))
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert saver.run(write_command(filename, content))
    assert_equal content, saver.read(filename)
  end

  test '604', %w(
    write() fails
    when its dir-name does not already exist
  ) do
    dirname = 'groups/5e/96/04'
    # no saver.create(dirname)
    filename = dirname + '/readme.md'
    refute saver.run(write_command(filename, 'bonjour'))
    assert saver.run(read_command(filename)).is_a?(FalseClass)
  end

  test '605', %w(
    write() fails
    when its file-name already exists
  ) do
    dirname = 'groups/73/F6/05'
    assert saver.run(create_command(dirname))
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert saver.run(write_command(filename, first_content))
    refute saver.run(write_command(filename, 'second-content'))
    assert_equal first_content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : append()

  test '606', %w(
    append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'groups/69/16/06'
    assert saver.run(create_command(dirname))
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert saver.run(write_command(filename, content))
    more = 'some-more'
    assert saver.run(append_command(filename, more))
    assert_equal content+more, saver.read(filename)
  end

  test '607', %w(
    append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'groups/96/16/07'
    # no saver.run(create_command(dirname))
    filename = dirname + '/readme.md'
    assert saver.run(append_command(filename, 'greetings')).is_a?(FalseClass)
    assert saver.run(read_command(filename)).is_a?(FalseClass)
  end

  test '608', %w(
    append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'groups/96/16/08'
    assert saver.run(create_command(dirname))
    filename = dirname + '/hiker.h'
    # no saver.run(write_command(filename, '...'))
    assert saver.run(append_command(filename, 'int main(void);')).is_a?(FalseClass)
    assert saver.run(read_command(filename)).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : read()

  test '609',
  'read() gives back what a successful write() accepts' do
    dirname = 'groups/FD/F6/09'
    assert saver.run(create_command(dirname))
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.run(write_command(filename, content))
    assert_equal content, saver.read(filename)
  end

  test '610',
  'read() returns false given a non-existent file-name' do
    filename = 'groups/1z/26/10/not-there.txt'
    assert saver.run(read_command(filename)).is_a?(FalseClass)
  end

  test '611',
  'read() returns false given an existing dir-name' do
    dirname = 'groups/2f/76/11'
    assert saver.run(create_command(dirname))
    assert saver.run(read_command(dirname)).is_a?(FalseClass)
  end

end
