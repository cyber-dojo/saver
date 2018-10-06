require_relative 'test_base'

class ExternalDiskWriterTest < TestBase

  def self.hex_prefix
    'FDF13'
  end

  def disk
    externals.disk
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '436', %w(
  dir.name is based on /grouper/ids/
  reveals id is split 2-8
  and can optionally take avatar-index ) do
    dir = disk['6BD45B7083']
    assert_equal '/grouper/ids/6B/D45B7083', dir.name
    dir = disk['2FA591B2C8',13]
    assert_equal '/grouper/ids/2F/A591B2C8/13', dir.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'dir.exists? is false before dir.make and true after' do
    dir = disk['FCFDC8BD58']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'dir.read() reads back what dir.write() wrote' do
    dir = disk['F7C14DC1B8']
    dir.make
    filename = 'limerick.txt'
    content = 'the boy stood on the burning deck'
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'dir.completions() returns dir names with common 6-char prefix' do
    ids = [
      '93769k' + '36DF',
      '937690' + 'D157',
      '937690' + '837B',
      '937690' + '07A2',
    ]
    ids.each{ |id| disk[id].make }
    expected = ids[1..-1].map{ |id|
      "/grouper/ids/#{id[0..1]}/#{id[2..-1]}"
    }.sort
    assert_equal expected, disk['937690'].completions.sort
  end

end