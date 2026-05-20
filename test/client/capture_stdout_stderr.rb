module CaptureStdoutStderr

  def capture_stdout_stderr
    begin
      uncaptured_stdout = $stdout
      uncaptured_stderr = $stderr
      old_stdout_stream = Thread.current[:stdout_stream]
      old_stderr_stream = Thread.current[:stderr_stream]
      captured_stdout = StringIO.new(+'', 'w')
      captured_stderr = StringIO.new(+'', 'w')
      $stdout = captured_stdout
      $stderr = captured_stderr
      Thread.current[:stdout_stream] = captured_stdout
      Thread.current[:stderr_stream] = captured_stderr
      yield uncaptured_stdout, uncaptured_stderr
      [ captured_stdout.string, captured_stderr.string ]
    ensure
      Thread.current[:stdout_stream] = old_stdout_stream
      Thread.current[:stderr_stream] = old_stderr_stream
      $stdout = uncaptured_stdout
      $stderr = uncaptured_stderr
    end
  end

end
