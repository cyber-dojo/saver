require_relative 'test_base'
require_relative '../src/saver'

class SaverTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha

  test '190', %w( sha is sha of image's git commit ) do
    sha = saver.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready

  test '602',
  %w( ready? is always true ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()

  test '437',
  'exists? is true after write' do
    name = 'groups/FD/F4/37'
    refute saver.exists?(name)
    assert saver.write(name + '/manifest.json', '{}')
    assert saver.exists?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  test '640', %w(
    write() succeeds
    when its dir-name does not already exist
  ) do
    filename = 'groups/5e/94/Aa/readme.md'
    content = 'bonjour'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '641', %w(
    write() succeeds
    when its file-name does not already exist
  ) do
    filename = 'groups/73/Ff/69/readme.md'
    content = 'greetings'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '642', %w(
    write() does nothing and returns false
    when its file-name already exists
  ) do
    filename = 'groups/1A/23/Cc/readme.md'
    content = 'welcome'
    assert saver.write(filename, content)
    refute saver.write(filename, 'different')
    assert_equal content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  test '841', %w(
    append() does nothing and returns false
    when its dir-name does not already exists
  ) do
    filename = 'groups/96/18/59/readme.md'
    content = 'greetings'
    refute saver.append(filename, content)
    assert_nil saver.read(filename)
  end

  test '842', %w(
    append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'groups/96/18/59'
    dot_h = "#{dirname}/hiker.h"
    content = 'greetings'
    assert saver.write(dot_h, content)
    assert_equal content, saver.read(dot_h)
    dot_c = "#{dirname}/hiker.c"
    refute saver.append(dot_c, content)
    assert_nil saver.read(dot_c)
  end

  test '843', %w(
    append() appends to the end
    when its file-name already exists
  ) do
    filename = 'groups/69/1b/2B/readme.md'
    content = 'helloooo'
    assert saver.write(filename, content)
    assert saver.append(filename, 'more-content')
    assert_equal content+'more-content', saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  test '438',
  'read() reads back what write() writes' do
    filename = 'groups/FD/F4/38/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '439',
  'read() a non-existant file is nil' do
    filename = 'groups/12/23/34/not-there.txt'
    assert_nil saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_read()

  test '440',
  'batch_read() is a read() BatchMethod' do
    dirname = 'groups/34/56/78/'
    there_not = dirname + 'there-not.txt'
    there_yes = dirname + 'there-yes.txt'
    assert saver.write(there_yes, 'content is this')
    reads = saver.batch_read([there_not, there_yes])
    assert_equal [nil,'content is this'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '441',
  'batch_read() can read across different sub-dirs' do
    filename1 = 'groups/C1/bc/1A/1/kata.id'
    assert saver.write(filename1, 'be30e5')
    filename2 = 'groups/C1/bc/1A/14/kata.id'
    assert saver.write(filename2, 'De02CD')
    reads = saver.batch_read([filename1, filename2])
    assert_equal ['be30e5','De02CD'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_false()

  test 'F45',
  'batch_until_false() runs commands until one is false' do
    filename = 'groups/Bc/99/48/punchline.txt'
    content = 'thats medeira cake'
    commands = [
      ['write',filename,content],          # true
      ['read',filename],                   # true
      ['append',filename,content],         # true
      ['append',filename,content],         # true
      ['write',filename,content]           # false
    ]
    results = saver.batch_until_false(commands)
    assert_equal [true,content,true,true,false], results
    expected = content * 3
    assert_equal expected, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_true()

  test 'A23',
  'batch_until_true() runs commands until one is true' do
    commands = [
      ['exists?', 'groups/12/34/45'], # false
      ['exists?', 'groups/12/34/67'], # false
      ['write',   'groups/12/34/manifest.json', '{}'], # true
      ['read',    'groups/12/34/manifest.json']        # not processed
    ]
    results = saver.batch_until_true(commands)
    assert_equal [false,false,true], results
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: batch_until_false() append()
  # TODO: batch_until_false() raises for unknown command
  # TODO: batch_until_false() raises for incorrect number of args
  # TODO: all raise for args not being string - rack-dispatcher

end
