require_relative 'test_base'
require 'tempfile'

class FileSpeedTest < TestBase

  def self.id58_prefix
    '34E'
  end

  test '4D7', %w( test affect on speed of locking an append ) do
    f0 = Tempfile.new('append-speed-test', '/tmp')
    f1 = Tempfile.new('append-speed-test', '/tmp')
    append_mode = File::WRONLY | File::APPEND
    read_mode = File::RDONLY
    content = '{"s":23,"t":[1,2,3,4,5,6,7],"u":"blah"}'

    unlocked_append = -> {
      File.open(f0.path, append_mode) do |fd|
        fd.write(content)
      end
    }
    locked_append = -> {
      File.open(f1.path, append_mode) do |fd|
        fd.flock(File::LOCK_EX)
        fd.write(content)
      end
    }
    repeats = 42
    t0,t1 = two_timed(repeats, [unlocked_append,locked_append])
    c0 = File.open(f0.path, read_mode) { |fd| fd.read }
    c1 = File.open(f1.path, read_mode) { |fd| fd.read }
    assert_equal content*repeats, c0
    assert_equal content*repeats, c1
    f0.delete
    f1.delete
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0} unlocked_append (#{repeats})"
    diagnostic += "\n#{'%.5f' % t1} locked_append (#{repeats})"
    # puts diagnostic
    # 0.00047 unlocked_append (42)
    # 0.00065 locked_append (42)
    # assert t0 < t1, diagnostic
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '4D8', %w( test affect on speed of locking a read ) do
    f0 = Tempfile.new('read-speed-test', '/tmp')
    f1 = Tempfile.new('read-speed-test', '/tmp')
    write_mode = File::WRONLY
    read_mode = File::RDONLY
    content = '{"s":23,"t":[1,2,3,4,5,6,7],"u":"blah"}'
    File.open(f0.path, write_mode) { |fd| fd.write(content) }
    File.open(f1.path, write_mode) { |fd| fd.write(content) }

    unlocked_reads = []
    unlocked_read = -> {
      File.open(f0.path, read_mode) do |fd|
        unlocked_reads << fd.read
      end
    }
    locked_reads = []
    locked_read = -> {
      File.open(f1.path, read_mode) do |fd|
        fd.flock(File::LOCK_EX)
        locked_reads << fd.read
      end
    }
    repeats = 42
    t0,t1 = two_timed(repeats, [unlocked_read,locked_read])
    assert_equal [content]*repeats, unlocked_reads
    assert_equal [content]*repeats, locked_reads
    f0.delete
    f1.delete
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0} unlocked_read (#{repeats})"
    diagnostic += "\n#{'%.5f' % t1} locked_read (#{repeats})"
    # puts diagnostic
    # 0.00061 unlocked_read (42)
    # 0.00067 locked_read (42)
    # assert t0 < t1, diagnostic
  end

end
