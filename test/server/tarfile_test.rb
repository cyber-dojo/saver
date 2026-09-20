require_relative 'test_base'
require_source 'lib/tarfile_writer'

class TarFileTest < TestBase

  test '80B365', %w(
  | writing content where .size != .bytesize does not throw
  ) do
    utf8 = [226].pack('U*')
    refute_equal utf8.size, utf8.bytesize
    TarFile::Writer.new.write('hello.txt', utf8)
    does_not_throw = true
    assert does_not_throw
  end

end
