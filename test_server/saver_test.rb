require_relative 'test_base'
require_relative '../src/saver'

class SaverTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  def saver
    Saver.new
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exist? make?

  test '435',
  'exist? can already be true' do
    assert saver.exist?('/tmp')
  end

  test '436',
  'make? succeeds once then fails' do
    name = '/cyber-dojo/groups/FD/F4/36'
    assert saver.make?(name)
    refute saver.make?(name)
    refute saver.make?(name)
  end

  test '437',
  'exists? is true after make? is true' do
    name = '/cyber-dojo/groups/FD/F4/37'
    refute saver.exist?(name)
    assert saver.make?(name)
    assert saver.exist?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  test '640',
  'write() does nothing and returns false when its dir does not already exist' do
    filename = '/cyber-dojo/groups/5e/94/Aa/readme.md'
    content = 'bonjour'
    refute saver.write(filename, content)
    assert_nil saver.read(filename)
  end

  test '641',
  'write() succeeds when its dir exists but its filename does not' do
    filename = '/cyber-dojo/groups/73/Ff/69/readme.md'
    content = 'greetings'
    assert saver.make?(File.dirname(filename))
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '642',
  'write() does nothing and returns false when its filename already exists' do
    filename = '/cyber-dojo/groups/1A/23/Cc/readme.md'
    content = 'welcome'
    assert saver.make?(File.dirname(filename))
    assert saver.write(filename, content)
    refute saver.write(filename, 'other content')
    assert_equal content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  test '840',
  'append() does nothing and returns false when its dir does not already exist' do
    filename = '/cyber-dojo/groups/4c/12/B2/readme.md'
    content = 'bonjour'
    refute saver.append(filename, content)
    assert_nil saver.read(filename)
  end

  test '841',
  'append() does nothing and returns false when its file does not already exists' do
    filename = '/cyber-dojo/groups/96/18/59/readme.md'
    content = 'greetings'
    assert saver.make?(File.dirname(filename))
    refute saver.append(filename, content)
    assert_nil saver.read(filename)
  end

  test '842',
  'append() appends to the end when its file already exists' do
    filename = '/cyber-dojo/groups/69/1b/2B/readme.md'
    content = 'helloooo'
    assert saver.make?(File.dirname(filename))
    assert saver.write(filename, content)
    assert saver.append(filename, 'more-content')
    assert_equal content+'more-content', saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  test '438',
  'read() reads back what write() writes' do
    filename = '/cyber-dojo/groups/FD/F4/38/limerick.txt'
    content = 'the boy stood on the burning deck'
    saver.make?(File.dirname(filename))
    saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '439',
  'read() a non-existant file is nil' do
    filename = '/cyber-dojo/groups/12/23/34/not-there.txt'
    assert_nil saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_read()

  test '440',
  'batch_read() is a read() BatchMethod' do
    dirname = '/cyber-dojo/groups/34/56/78/'
    there_not = dirname + 'there-not.txt'
    there_yes = dirname + 'there-yes.txt'
    saver.make?(dirname)
    saver.write(there_yes, 'content is this')
    reads = saver.batch_read([there_not, there_yes])
    assert_equal [nil,'content is this'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '441',
  'batch_read() can read across different sub-dirs' do
    filename1 = '/cyber-dojo/groups/C1/bc/1A/1/kata.id'
    saver.make?(File.dirname(filename1))
    saver.write(filename1, 'be30e5')
    filename2 = '/cyber-dojo/groups/C1/bc/1A/14/kata.id'
    saver.make?(File.dirname(filename2))
    saver.write(filename2, 'De02CD')
    reads = saver.batch_read([filename1, filename2])
    assert_equal ['be30e5','De02CD'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch()

  test 'F44',
  'batch() api starting example' do
    filename = '/cyber-dojo/groups/e8/9e/23/joke.txt'
    content = 'why is this cake 50p and all the rest are 25p'
    commands = [
      ['make?',File.dirname(filename)],
      ['write',filename,content]
    ]
    results = saver.batch(commands)
    assert results[0], 'make?'
    assert results[1], 'write'
    assert_equal content, saver.read(filename), 'read'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F45',
  'batch() does not run trailing commands when command fails' do
    filename = '/cyber-dojo/groups/Bc/99/48/punchline.txt'
    content = 'thats medeira cake'
    commands = [
      ['make?',File.dirname(filename)], # true
      ['make?',File.dirname(filename)], # false
      ['write',filename,content]        # not processed
    ]
    results = saver.batch(commands)
    assert_equal [true,false], results
    assert_nil saver.read(filename)
  end

  # TODO: batch() exists? append()
  # TODO: batch() raises for unknown command
  # TODO: batch() raises for incorrect number of args
  # TODO: all raise for args not being string - rack-dispatcher

end
