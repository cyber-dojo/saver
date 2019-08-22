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

  test '435',
  'exist? can already be true' do
    assert saver.exist?('/tmp')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '436',
  'make succeeds once then fails' do
    name = '/cyber-dojo/groups/FD/F4/36'
    assert saver.make?(name)
    refute saver.make?(name)
    refute saver.make?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'exists? is true after make? is true' do
    name = '/cyber-dojo/groups/FD/F4/37'
    refute saver.exist?(name)
    assert saver.make?(name)
    assert saver.exist?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'read() reads back what write() writes' do
    filename = '/cyber-dojo/groups/FD/F4/38/limerick.txt'
    content = 'the boy stood on the burning deck'
    saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'read() a non-existant file is nil' do
    filename = '/cyber-dojo/groups/12/23/34/not-there.txt'
    assert_nil saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '440',
  'reads() is a read-BatchMethod' do
    dir = '/cyber-dojo/groups/34/56/78/'
    there_not = dir + 'there-not.txt'
    there_yes = dir + 'there-yes.txt'
    saver.write(there_yes, 'content is this')
    reads = saver.reads([there_not, there_yes])
    assert_equal [nil,'content is this'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '441',
  'reads() can read across different sub-dirs' do
    filename1 = '/cyber-dojo/groups/C1/bc/1A/1/kata.id'
    saver.write(filename1, 'be30e5')
    filename2 = '/cyber-dojo/groups/C1/bc/1A/14/kata.id'
    saver.write(filename2, 'De02CD')
    reads = saver.reads([filename1, filename2])
    assert_equal ['be30e5','De02CD'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '539',
  'append() appends to the end' do
    filename = '/cyber-dojo/groups/FD/F4/39/readme.md'
    content = 'hello world'
    saver.append(filename, content)
    assert_equal content, saver.read(filename)
    saver.append(filename, content.reverse)
    assert_equal "#{content}#{content.reverse}", saver.read(filename)
  end

end
