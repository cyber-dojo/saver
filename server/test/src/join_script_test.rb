require_relative 'test_base'

class JoinScriptTest < TestBase

  def self.hex_prefix
    '69252'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0E9',
  'sdfsdfdsf' do
    id = '588AA6D4FB'
    command = "flock /tmp/#{id} /app/src/join.rb #{pathed(id)}"
    logging = false
    stdout,stderr,status = shell.exec(command, logging)

    #puts ":stdout:#{stdout}:"
    #puts ":stderr:#{stderr}:"
    #puts ":status:#{status}:"
    assert_equal 0, status
  end

  private

  def shell
    externals.shell
  end

  def pathed(id)
    "#{externals.grouper.path}/#{outer(id)}/#{inner(id)}"
  end

  def outer(id)
    id[0..1]  # 2-chars long. eg 'e5'
  end

  def inner(id)
    id[2..-1] # 8-chars long. eg '6aM327PE'
  end

end
