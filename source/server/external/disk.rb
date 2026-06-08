require 'fileutils'
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
      # Returns true iff dirname did not already exist and is now made (false if
      # it already existed, or a non-directory is in the way). That boolean is
      # load-bearing and must be atomic: IdGenerator uses it to detect an id
      # collision (retry on false) and group_v2 uses it to claim an unused index.
      # FileUtils.mkdir_p is idempotent and cannot report whether it created
      # anything, so create any missing parents with it (matching mkdir -p) and
      # then claim the leaf with Dir.mkdir, a single atomic syscall that raises
      # Errno::EEXIST iff the leaf already exists. make_dirs feeds dirs sorted
      # shallow-to-deep, so a parent is always claimed before its children.
      # Genuine system faults (e.g. ENOSPC, EACCES) propagate, as in file_create.
      path = path_name(dirname)
      FileUtils.mkdir_p(File.dirname(path))
      Dir.mkdir(path)
      true
    rescue Errno::EEXIST # already exists, or a non-dir is in the way: "taken"
      false
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
           Errno::EEXIST => e # file already exists
      @last_error = e
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_write(filename, content)
      # Errno::ENOSPC (no space left on device) will
      # be caught by RackDispatcher --> status=500
      mode = File::WRONLY | File::TRUNC | File::CREAT
      File.open(path_name(filename), mode) do |fd|
        fd.write(content)
      end
      true
    rescue Errno::ENOENT => e # dir does not exist
      @last_error = e
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_append(filename, content)
      # Errno::ENOSPC (no space left on device) will
      # be caught by RackDispatcher --> status=500
      mode = File::WRONLY | File::APPEND
      File.open(path_name(filename), mode) do |fd|
        fd.write(content)
      end
      true
    rescue Errno::EISDIR, # file is a dir!
           Errno::ENOENT => e # file does not exist
      @last_error = e
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def file_read(filename)
      mode = File::RDONLY
      File.open(path_name(filename), mode) do |fd|
        fd.read
      end
    rescue Errno::EISDIR, # file is a dir!,
           Errno::ENOENT => e # file does not exist
      @last_error = e
      false
    end

    # - - - - - - - - - - - - - - - - - - - - - - - -

    def path_name(s)
      File.join('', @root_dir, s) # an /absolute/path
    end

  end

end
