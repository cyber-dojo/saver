module TestHelpersDisk

  def dir_exists_command(key)
    disk.dir_exists_command(key)
  end

  def dir_make_command(key)
    disk.dir_make_command(key)
  end

  def file_create_command(key, value)
    disk.file_create_command(key, value)
  end

  def file_write_command(key, value)
    disk.file_write_command(key, value)
  end

  def file_append_command(key, value)
    disk.file_append_command(key, value)
  end

  def file_read_command(key)
    disk.file_read_command(key)
  end

end
