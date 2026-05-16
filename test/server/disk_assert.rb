require_relative 'test_base'

class DiskAssertTest < TestBase

  def id58_setup
    externals.instance_exec {
      @disk = External::Disk.new('tmp/cyber-dojo')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - -

  disk_tests 'FA2538',
  'assert() raises when its command is not true' do
    dirname = 'groups/Fw/FP/3p'
    error = assert_raises(RuntimeError) {
      disk.assert(dir_exists_command(dirname))
    }
    assert_equal "command != true: #{dir_exists_command(dirname).inspect}", error.message
    refute disk.run(dir_exists_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - -

  disk_tests 'FA2539',
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

  disk_tests 'FA253A',
  'assert() raises with command and error when @last_error is set' do
    dirname = 'groups/Fw/FP/3a'
    disk.assert(dir_make_command(dirname))
    filename = dirname + '/3a.events.json'
    error = assert_raises(RuntimeError) {
      disk.assert(file_read_command(filename))
    }
    assert_includes error.message, "command != true: #{file_read_command(filename).inspect}"
    assert_includes error.message, 'No such file or directory'
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'FA2166',
  'raises when no space left on device' do
    externals.instance_exec {
      # See docker-compose.yml volume one_k
      # See create_space_limited_volume() in bin/lib.sh
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
    message = "No space left on device @ rb_sys_fail_on_write - /one_k/#{filename}"
    assert_equal message, error.message
  end

end
