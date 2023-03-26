require_relative 'test_base'

class ShellTest < TestBase

  def self.id58_prefix
    'C89'
  end

  # - - - - - - - - - - - - - - - - -

  test 'DBB',
  'assert_exec(*commands) returns stdout when the commands all succeed' do
    assert_equal 'Hello', shell.assert_exec('echo -n Hello')
  end

  test '0B8',
  'assert_cd_exec(path,*commands) returns stdout when the cd and the commands succeeds' do
    assert_equal 'Hello', shell.assert_cd_exec('.', 'echo -n Hello')
  end

  # - - - - - - - - - - - - - - - - -

  test 'AF6',
  'assert_exec(*commands) raises when a command fails' do
    error = assert_raises { shell.assert_exec('zzzz') }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert json['stderr'].end_with?("sh: zzzz: not found\n"), json['stderr']
    assert_equal 127,  json['exit_status']
  end

  test 'ACD',
  'assert_cd_exec(path,*commands) raises when the cd fails' do
    error = assert_raises { shell.assert_cd_exec('zzzz', 'echo -n Hello') }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    expected_stderr = "sh: cd: line 0: can't cd to zzzz: No such file or directory\n"
    assert json['stderr'].end_with?(expected_stderr), json['stderr']
    assert_equal 2,  json['exit_status']
  end

  test '995',
  'assert_cd_exec(path,*commands) raises when a command fails' do
    error = assert_raises { shell.assert_cd_exec('.', 'zzzz') }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert json['stderr'].end_with?("sh: zzzz: not found\n"), json['stderr']
    assert_equal 127,  json['exit_status']
  end

end
