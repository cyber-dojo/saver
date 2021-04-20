# frozen_string_literal: true
require_source 'external/disk_core'

class DiskFake

  def initialize
    @@dirs ||= {}
    @@files ||= {}
  end

  include DiskCore

  private

  def dir_exists?(key)
    dir?(path_name(key))
  end

  def dir_make(key)
    if dir_exists?(key)
      false
    else
      @@dirs[path_name(key)] = true
    end
  end

  def file_create(key, value)
    path = path_name(key)
    if dir?(File.dirname(path)) && !file?(path)
      @@files[path] = value
      true
    else
      false
    end
  end

  def file_append(key, value)
    path = path_name(key)
    if dir?(File.dirname(path)) && file?(path)
      @@files[path] += value
      true
    else
      false
    end
  end

  def file_read(key)
    @@files[path_name(key)] || false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', 'tmp', 'cyber-dojo', key)
  end

  def dir?(key)
    @@dirs.has_key?(key)
  end

  def file?(key)
    @@files.has_key?(key)
  end

end
