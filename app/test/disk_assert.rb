require_relative 'test_base'

class DiskAssertTest < TestBase

  def self.id58_prefix
    'FA2'
  end

  def id58_setup
    externals.instance_exec {
      @disk = External::Disk.new('tmp/cyber-dojo')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  disk_tests '538',
  'assert() raises when its command is not true' do
    dirname = 'groups/Fw/FP/3p'
    error = assert_raises(RuntimeError) {
      disk.assert(dir_exists_command(dirname))
    }
    assert_equal 'command != true', error.message
    refute disk.run(dir_exists_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - -

  disk_tests '539',
  'assert() returns command result when command is true' do
    dirname = 'groups/sw/EP/7K'
    filename = dirname + '/' + '3.events.json'
    content = '{"colour":"red"}'
    disk.assert(dir_make_command(dirname))
    disk.assert(file_create_command(filename, content))
    read = disk.assert(file_read_command(filename))
    assert_equal content, read
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '166',
  'raises when no space left on device' do
    externals.instance_exec {
      # See docker-compose.yml
      # See scripts/containers_up.sh create_space_limited_volume()
      @disk = External::Disk.new('one_k')
    }
    dirname = '166'
    filename = '166/file'
    content = 'x'*1024
    disk.assert(dir_make_command(dirname))
    disk.assert(file_create_command(filename, content))
    error = assert_raises(Errno::ENOSPC) {
      disk.assert(file_append_command(filename, content*16))
    }
    message = "No space left on device @ io_write - /one_k/#{filename}"
    assert_equal message, error.message
  end

end
