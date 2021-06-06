require 'open3'
require_relative '../disk_api'

module External

  class Disk

    def initialize(root_dir)
      @root_dir = root_dir
    end

    attr_reader :root_dir

    include DiskApi

    private

    def dir_exists?(dirname)
      Dir.exist?(path_name(dirname))
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def dir_make(dirname)
      # Returns true iff key's dir does not already exist and
      # is made. Can't find a Ruby library method for this
      # (FileUtils.mkdir_p does not tell) so using shell.
      #   -p creates intermediate dirs as required.
      #   -v verbose mode, output each dir actually made
      command = "mkdir -vp '#{path_name(dirname)}'"
      stdout,stderr,r = Open3.capture3(command)
      stdout != '' && stderr === '' && r.exitstatus === 0
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_create(filename, content)
      # Errno::ENOSPC (no space left on device) will
      # be caught by RackDispatcher --> status=500
      mode = File::WRONLY | File::CREAT | File::EXCL
      File.open(path_name(filename), mode) do |fd|
        fd.write(content)
      end
      true
    rescue Errno::ENOENT, # dir does not exist
           Errno::EEXIST  # file already exists
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_write(filename, content)
      # Errno::ENOSPC (no space left on device) will
      # be caught by RackDispatcher --> status=500
      mode = File::WRONLY | File::TRUNC | File::CREAT
      File.open(path_name(filename), mode) do |fd|
        fd.flock(File::LOCK_EX)
        fd.write(content)
      end
      true
    rescue Errno::ENOENT # dir does not exist
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_append(filename, content)
      # Errno::ENOSPC (no space left on device) will
      # be caught by RackDispatcher --> status=500
      mode = File::WRONLY | File::APPEND
      File.open(path_name(filename), mode) do |fd|
        fd.flock(File::LOCK_EX)
        fd.write(content)
      end
      true
    rescue Errno::EISDIR, # file is a dir!
           Errno::ENOENT  # file does not exist
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_read(filename)
      mode = File::RDONLY
      File.open(path_name(filename), mode) do |fd|
        fd.flock(File::LOCK_EX)
        fd.read
      end
    rescue Errno::EISDIR, # file is a dir!,
           Errno::ENOENT  # file does not exist
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def path_name(s)
      File.join('', @root_dir, s) # an /absolute/path
    end

  end

end
