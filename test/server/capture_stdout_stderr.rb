module CaptureStdoutStderr

  def capture_stdout_stderr
    begin
      uncaptured_stdout = $stdout
      uncaptured_stderr = $stderr
      old_stdout_stream = Thread.current[:stdout_stream]
      old_stderr_stream = Thread.current[:stderr_stream]
      captured_stdout = StringIO.new(+'', 'w')
      captured_stderr = StringIO.new(+'', 'w')
      # Set only the per-thread streams, never the process-global $stdout/$stderr.
      # Swapping the global is not thread-safe: under Minitest's concurrent test
      # execution another thread's write would land in this thread's buffer.
      # Production logging reads Thread.current[:stdout_stream] via the
      # stdout_stream/stderr_stream accessors, so per-thread capture suffices.
      Thread.current[:stdout_stream] = captured_stdout
      Thread.current[:stderr_stream] = captured_stderr
      yield uncaptured_stdout, uncaptured_stderr
      [ captured_stdout.string, captured_stderr.string ]
    ensure
      Thread.current[:stdout_stream] = old_stdout_stream
      Thread.current[:stderr_stream] = old_stderr_stream
    end
  end

end
