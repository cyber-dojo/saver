# frozen_string_literal: true

require_relative 'test_base'
require_source 'lib/tarfile_reader'
require_source 'lib/tarfile_writer'

class TarFileTest < TestBase

  test '80B364', %w(
  | simple tar round-trip
  ) do
    writer = TarFile::Writer.new
    expected = {
      'hello.txt' => 'greetings earthlings...',
      'hiker.c' => '#include <stdio.h>'
    }
    expected.each do |filename, content|
      writer.write(filename, content)
    end
    reader = TarFile::Reader.new(writer.tar_file)
    actual = reader.files
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - -

  test '80B365', %w(
  | writing content where .size != .bytesize does not throw
  ) do
    utf8 = [226].pack('U*')
    refute_equal utf8.size, utf8.bytesize
    TarFile::Writer.new.write('hello.txt', utf8)
    does_not_throw = true
    assert does_not_throw
  end

  # - - - - - - - - - - - - - - - - - -

  test '80B366', %w(
  | empty file round-trip
  ) do
    writer = TarFile::Writer.new
    filename = 'greeting.txt'
    writer.write(filename, '')
    read = TarFile::Reader.new(writer.tar_file).files[filename]
    assert_equal '', read
  end
end
