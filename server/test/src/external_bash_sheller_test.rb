require_relative 'test_base'
require_relative 'stdout_logger_spy'

class ExternalBashShellerTest < TestBase

  def self.hex_prefix
    'C89D2'
  end

  def hex_setup
    @real_logger = externals.logger
    @spy_logger = StdoutLoggerSpy.new
    externals.logger = @spy_logger
  end

  def hex_teardown
    externals.logger = @real_logger
  end

  # - - - - - - - - - - - - - - - - -
  # exec()
  # - - - - - - - - - - - - - - - - -

  test 'DBB',
  'exec(cmd) succeeds with output' do
    exec('echo Hello')
    assert_status 0
    assert_stdout "Hello\n"
    assert_stderr ''
    assert_log []
  end

  # - - - - - - - - - - - - - - - - -

  test '490',
  'exec(cmd) succeeds with no output' do
    exec('false')
    assert_status 1
    assert_stdout ''
    assert_stderr ''
    assert_log [
      'COMMAND:false',
      'STATUS:1',
      'STDOUT:',
      'STDERR:'
    ]
  end

  # - - - - - - - - - - - - - - - - -

  test '46B',
  'exec(cmd) fails with output' do
    exec('sed salmon')
    assert_status 1
    assert_stdout ''
    assert_stderr "sed: unmatched 'a'\n"
    assert_log [
      'COMMAND:sed salmon',
      'STATUS:1',
      'STDOUT:',
      "STDERR:sed: unmatched 'a'\n"
    ]
  end

  # - - - - - - - - - - - - - - - - -

  test '6D5',
  'exec(cmd,logging=false) with output' do
    exec('sed salmon', logging = false)
    assert_status 1
    assert_stdout ''
    assert_stderr "sed: unmatched 'a'\n"
    assert_log []
  end

  # - - - - - - - - - - - - - - - - -

  test 'AF6',
  'exec(cmd) raises' do
    assert_raises { exec('zzzz') }
    assert_log [
      'COMMAND:zzzz',
      'RAISED-CLASS:Errno::ENOENT',
      'RAISED-TO_S:No such file or directory - zzzz'
    ]
  end

  # - - - - - - - - - - - - - - - - -
  # cd_exec()
  # - - - - - - - - - - - - - - - - -

  test 'E18',
  'when the cd_exec command succeeds output is captured and exit-status is zero' do
    cd_exec('.', 'echo Hello')
    assert_status 0
    assert_stdout 'Hello' + "\n"
    assert_stderr ''
    assert_log []
  end

  test '373',
  'when the cd_exec command fails output is captured and exit-status is non zero' do
    cd_exec('.', 'zzzz')
    refute_status 0
    assert_stdout ''
    assert_stderr 'sh: zzzz: not found' + "\n"
    assert_log [
      'COMMAND:cd . && zzzz',
      'STATUS:127',
      'STDOUT:',
      "STDERR:sh: zzzz: not found" + "\n"
    ]
  end

  test '565',
  "when the cd_exec's cd fails the command is not executed and exit-status is non-zero" do
    cd_exec('zzzz', 'echo Hello')
    refute_status 0
    assert_stdout ''
    assert_stderr "sh: cd: line 1: can't cd to zzzz" + "\n"
    assert_log [
      'COMMAND:cd zzzz && echo Hello',
      'STATUS:2',
      'STDOUT:',
      "STDERR:sh: cd: line 1: can't cd to zzzz" + "\n"
    ]
  end

  private

  def shell
    externals.shell
  end

  def exec(command, logging = true)
    @stdout,@stderr,@status = shell.exec(command, logging)
  end

  def cd_exec(path, command, logging = true)
    @stdout,@stderr,@status = shell.cd_exec(path, command, logging)
  end

  # - - - - - - - - - - - - - - - - -

  def assert_status(expected)
    assert_equal expected, @status
  end

  def refute_status(expected)
    refute_equal expected, @status
  end

  # - - - - - - - - - - - - - - - - -

  def assert_stdout(expected)
    assert_equal expected, @stdout
  end

  def assert_stderr(expected)
    assert_equal expected, @stderr
  end

  def assert_log(expected)
    line = '-' * 40
    expected.unshift(line) unless expected == []
    assert_equal expected, externals.logger.spied
  end

end