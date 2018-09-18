require 'open3'

class ExternalBashSheller

  def initialize(externals)
    @externals = externals
  end

  attr_reader :parent

  def cd_exec(path, command, logging = true)
    exec("cd #{path} && #{command}", logging)
  end

  def exec(command, logging = true)
    begin
      stdout,stderr,r = Open3.capture3(command)
      status = r.exitstatus
      if status != success && logging
        logger << line
        logger << "COMMAND:#{command}"
        logger << "STATUS:#{status}"
        logger << "STDOUT:#{stdout}"
        logger << "STDERR:#{stderr}"
      end
      [stdout,stderr,status]
    rescue StandardError => error
      logger << line
      logger << "COMMAND:#{command}"
      logger << "RAISED-CLASS:#{error.class.name}"
      logger << "RAISED-TO_S:#{error.to_s}"
      raise error
    end
  end

  def success
    0
  end

  private

  def logger
    @externals.logger
  end

  def line
    '-' * 40
  end

end