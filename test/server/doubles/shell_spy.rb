# Delegates all shell calls to the real shell and records each
# command string in a log for test assertions.
class ShellSpy

  def initialize(real_shell)
    @real = real_shell
    @commands = []
  end

  attr_reader :commands

  def assert_cd_exec(path, *commands)
    @commands << commands
    @real.assert_cd_exec(path, *commands)
  end

  # def assert_exec(*commands)
  #   @commands << commands
  #   @real.assert_exec(*commands)
  # end

  def cd_exec(path, command)
    @commands << command
    @real.cd_exec(path, command)
  end

end
