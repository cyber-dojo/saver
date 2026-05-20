require_relative '../lib/utf8_clean'
require 'open3'

module External

  class Shell

    def assert_cd_exec(path, *commands)
      assert_exec(["cd #{path}"] + commands)
    end

    def cd_exec(path, command)
      assert_cd_exec(path, command)
    rescue => e
      stderr_stream.puts e.message
      stderr_stream.flush
    end

    def assert_exec(*commands)
      command = 'sh -c ' + quoted(commands.join(' && '))
      stdout,stderr,r = Open3.capture3(command)
      stdout = Utf8::clean(stdout)
      stderr = Utf8::clean(stderr)
      exit_status = r.exitstatus
      unless stderr.empty? || stderr.start_with?('Preparing worktree')
        stderr_stream.puts stderr
        stderr_stream.flush
      end
      unless success?(exit_status)
        diagnostic = {
          command:command,
          stdout:stdout,
          stderr:stderr,
          exit_status:exit_status
        }
        raise diagnostic.to_json
      end
      stdout
    end

    private

    def stderr_stream
      Thread.current[:stderr_stream] || $stderr
    end

    def success?(status)
      status === 0
    end

    def quoted(s)
      '"' + s + '"'
    end

  end

end
