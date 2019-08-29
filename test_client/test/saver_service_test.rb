
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_fake'

class SaverTest < TestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  REAL_TEST_MARK = '<real>'
  FAKE_TEST_MARK = '<fake>'

  def fake_test?
    test_name.start_with?(FAKE_TEST_MARK)
  end

  def self.multi_test(hex_suffix, *lines, &block)
    real_lines = [REAL_TEST_MARK] + lines
    test(hex_suffix+'0', *real_lines, &block)
    fake_lines = [FAKE_TEST_MARK] + lines
    test(hex_suffix+'1', *fake_lines, &block)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def saver
    if fake_test?
      @saver ||= SaverFake.new
    else
      @saver ||= SaverService.new
    end
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
  # ready

  multi_test '602',
  %w( ready? is always true ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(), create()

  multi_test '431',
  'exists?(k) is false before create(k) and true after' do
    dirname = 'client/34/f7/a8'
    refute saver.exists?(dirname)
    assert saver.create(dirname)
    assert saver.exists?(dirname)
  end

  multi_test '432',
  'create succeeds once and then fails' do
    dirname = 'client/r5/s7/03'
    assert saver.create(dirname)
    refute saver.create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  multi_test '640', %w(
    write() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'client/32/fg/9j'
    assert saver.create(dirname)
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  multi_test '641', %w(
    write() fails
    when its dir-name does not already exist
  ) do
    dirname = 'client/5e/94/Aa'
    # saver.create(dirname) # missing
    filename = dirname + '/readme.md'
    refute saver.write(filename, 'bonjour')
    assert_nil saver.read(filename)
  end

  multi_test '642', %w(
    write() fails
    when its file-name already exists
  ) do
    dirname = 'client/73/Ff/69'
    assert saver.create(dirname)
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert saver.write(filename, first_content)
    refute saver.write(filename, 'second-content')
    assert_equal first_content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  multi_test '840', %w(
    append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'client/69/1b/2B'
    assert saver.create(dirname)
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert saver.write(filename, content)
    more = 'some-more'
    assert saver.append(filename, more)
    assert_equal content+more, saver.read(filename)
  end

  multi_test '841', %w(
    append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'client/96/18/59'
    # saver.create(dirname) # missing
    filename = dirname + '/readme.md'
    refute saver.append(filename, 'greetings')
    assert_nil saver.read(filename)
  end

  multi_test '842', %w(
    append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'client/96/18/59'
    assert saver.create(dirname)
    filename = dirname + '/hiker.h'
    # saver.write(filename, '...') # missing
    refute saver.append(filename, 'int main(void);')
    assert_nil saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  multi_test '437',
  'read() gives back what a successful write() accepts' do
    dirname = 'client/FD/F4/38'
    assert saver.create(dirname)
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  multi_test '438',
  'read() returns nil given a non-existent file-name' do
    filename = 'client/1z/23/e4/not-there.txt'
    assert_nil saver.read(filename)
  end

  multi_test '439',
  'read() returns nil given an existing dir-name' do
    dirname = 'client/2f/7k/3P'
    saver.create(dirname)
    assert_nil saver.read(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_read()

  multi_test '440',
  'batch_read() is a read() BatchMethod' do
    dirname = 'client/34/56/78'
    assert saver.create(dirname)
    there_not = dirname + '/there-not.txt'
    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    assert saver.write(there_yes, content)
    reads = saver.batch_read([there_not, there_yes])
    assert_equal [nil,content], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '441',
  'batch_read() can read across different sub-dirs' do
    dirname1 = 'client/C1/bc/1A/1'
    filename1 = dirname1 + '/kata.id'
    content1 = 'be30e5'
    assert saver.create(dirname1)
    assert saver.write(filename1, content1)
    dirname2 = 'client/C1/bc/1A/14'
    filename2 = dirname2 + '/kata.id'
    content2 = 'De02CD'
    assert saver.create(dirname2)
    assert saver.write(filename2, content2)

    reads = saver.batch_read([filename1, filename2])
    assert_equal [content1,content2], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_false()

  multi_test 'F45',
  'batch_until_false() runs commands until one is false' do
    dirname = 'client/Bc/99/48'
    filename = dirname + '/punchline.txt'
    # why is this cake 50p when all the rest are 25p ?
    content = 'thats madeira cake'
    commands = [
      ['create',dirname],                  # true
      ['write',filename,content],          # true
      ['read',filename],                   # content
      ['append',filename,content],         # true
      ['append',filename,content],         # true
      ['write',filename,content],          # false
      ['append',filename,content],         # not-processed
    ]
    results = saver.batch_until_false(commands)
    assert_equal [true,true,content,true,true,false], results
    expected = content * 3
    assert_equal expected, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_true()

  multi_test 'A23',
  'batch_until_true() runs commands until one is true' do
    commands = [
      ['exists?', 'client/12/34/45'], # false
      ['exists?', 'client/12/34/67'], # false
      ['create',  'client/12/34'],    # true
      ['read',    'client/abc.json']  # not processed
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
