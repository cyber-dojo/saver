require_relative 'grouper'
require_relative 'external_bash_sheller'
require_relative 'external_disk_writer'
require_relative 'external_id_generator'
require_relative 'external_singler'
require_relative 'external_stdout_logger'

class Externals

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def singler
    @singler ||= ExternalSingler.new
  end

  def id_generator
    @id_generator ||= ExternalIdGenerator.new(self)
  end
  def id_generator=(arg)
    @id_generator = arg
  end

  def logger
    @logger ||= ExternalStdoutLogger.new(self)
  end
  def logger=(arg)
    @logger = arg
  end

  def shell
    @shell ||= ExternalBashSheller.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new(self)
  end

end
