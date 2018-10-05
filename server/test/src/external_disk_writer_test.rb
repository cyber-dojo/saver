require_relative 'test_base'

class ExternalDiskWriterTest < TestBase

  def self.hex_prefix
    'FDF13'
  end

  def disk
    externals.disk
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'dir.name does not ends in /' do
    dir = disk['/tmp/437']
    assert_equal '/tmp/437', dir.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0DB',
  'dir.exists? is false before dir.make and true after' do
    dir = disk['/tmp/0DB']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D4C',
  'dir.read() reads back what dir.write() wrote' do
    dir = disk['/tmp/D4C']
    dir.make
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0CB',
  'dir.completions() returns dir names but not . or ..' do
    names = %w(
      /tmp/0CDnope
      /tmp/0CCalpha
      /tmp/0CCbeta
      /tmp/0CCgamma
    )
    names.each{ |name| disk[name].make }
    names.shift
    assert_equal names, disk['/tmp/0CC'].completions.sort
  end

  private # = = = = = = = = = = = = = = = =

  def filename
    'limerick.txt'
  end

  def content
    'the boy stood on the burning deck'
  end

end