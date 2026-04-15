require_relative 'test_base'

class ShellTest < TestBase

  test 'C89DBB', %w(
  | assert_exec(*commands) returns stdout when the commands all succeed
  ) do
    assert_equal 'Hello', shell.assert_exec('echo -n Hello')
  end

  test 'C890B8', %w(
  | assert_cd_exec(path,*commands) returns stdout when the cd and the commands succeeds
  ) do
    assert_equal 'Hello', shell.assert_cd_exec('.', 'echo -n Hello')
  end

  # - - - - - - - - - - - - - - - - -

  test 'C89AF6', %w(
  | assert_exec(*commands) writes to stderr and raises when a command fails
  ) do
    error = nil
    capture_stdout_stderr { error = assert_raises { shell.assert_exec('zzzz') } }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert json['stderr'].end_with?("sh: zzzz: not found\n"), json['stderr']
    assert_equal 127, json['exit_status']
  end

  test 'C89ACD', %w(
  | assert_cd_exec(path,*commands) writes to stderr and raises when the cd fails
  ) do
    error = nil
    capture_stdout_stderr { error = assert_raises { shell.assert_cd_exec('zzzz', 'echo -n Hello') } }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    expected_stderr = "sh: cd: line 0: can't cd to zzzz: No such file or directory\n"
    assert json['stderr'].end_with?(expected_stderr), json['stderr']
    assert_equal 2, json['exit_status']
  end

  test 'C89995', %w(
  | assert_cd_exec(path,*commands) writes to stderr and raises when a command fails
  ) do
    error = nil
    capture_stdout_stderr { error = assert_raises { shell.assert_cd_exec('.', 'zzzz') } }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert json['stderr'].end_with?("sh: zzzz: not found\n"), json['stderr']
    assert_equal 127, json['exit_status']
  end

  test 'C89h4k', %w(
  | cd_exec(path,command) does not raise when the command fails
  | whereas assert_cd_exec(path,command) writes to stderr and raises for the same command
  ) do
    _stdout, stderr = capture_stdout_stderr { shell.cd_exec('.', 'zzzz') }
    assert stderr.include?('zzzz'), stderr
    capture_stdout_stderr { assert_raises { shell.assert_cd_exec('.', 'zzzz') } }
  end

  test 'C89nR2', %w(
  | assert_exec(*commands) writes to stderr before raising when a command fails
  ) do
    _stdout, stderr = capture_stdout_stderr { assert_raises { shell.assert_exec('zzzz') } }
    assert stderr.include?('zzzz'), stderr
  end
end
