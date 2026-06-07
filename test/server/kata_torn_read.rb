require_relative 'test_base'

class KataTornReadTest < TestBase

  version_test 2, 'Tn6Wb1', %w(
  | Reproduces the torn-read window proven by strace: git merge --ff-only
  | rewrites the working-tree events.json via unlink + O_EXCL create + chunked
  | writes, so a concurrent reader can observe a partial file. events()/
  | read_events read the working-tree file directly (File.read), so a partial
  | events.json reaches json_parse and surfaces as a raw JSON::ParserError
  | instead of a clean result. This pins the current working-tree coupling;
  | once reads go through git this assertion inverts (the read succeeds from
  | the committed blob regardless of the working-tree file).
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => '', 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

      path = events_json_path(id)
      full = File.read(path)
      # Simulate a partial chunked write: only a prefix has landed.
      File.write(path, full[0, full.size / 2])

      assert_raises(JSON::ParserError) { kata_events(id) }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb2', %w(
  | Reproduces the ENOENT window proven by strace: between the unlink and the
  | O_EXCL create of events.json the path does not exist. events()/read_events
  | read the working-tree file directly, so file_read returns false and
  | disk.assert raises a raw "command != true ... No such file or directory".
  | This pins the current working-tree coupling; once reads go through git this
  | assertion inverts (the read succeeds from the committed blob).
  ) do
    in_kata do |id|
      File.delete(events_json_path(id))

      error = assert_raises(RuntimeError) { kata_events(id) }
      assert error.message.include?('No such file or directory'), error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb3', %w(
  | Live demonstration of the torn read under real concurrency, in-process (no
  | injection, no HTTP). A single writer thread streams sequential saves; each
  | save's git merge --ff-only rewrites the working-tree events.json (unlink +
  | O_EXCL create + chunked writes, per strace). Reader threads hammer
  | kata_events, whose read_events does a plain File.read of that working-tree
  | file. CRuby releases the GIL during the git subprocess and the read
  | syscall, so a read can land mid-rewrite and observe a partial file (JSON
  | parse error) or an absent file (No such file or directory). In-process
  | there is no transport layer, so the only way kata_events on a valid kata
  | can fail is this torn read. Asserts no read fails. Timing-dependent:
  | pre-refactor it is expected to catch the torn read and FAIL (the
  | deterministic tests above are the reliable proof); once reads go through
  | git it passes. Counts are tunable to widen the window.
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => 'x' * 2000, 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }

      # Grow events.json first so each later save rewrites it across more
      # write() chunks, widening the torn-read window.
      40.times { |i| kata_ran_tests(id, i + 1, files, stdout, stderr, 0, red_summary) }
      next_index = 41

      stop        = false
      mutex       = Mutex.new
      read_errors = []
      reads       = 0

      readers = 8.times.map do
        Thread.new do
          until mutex.synchronize { stop }
            begin
              kata_events(id)
              mutex.synchronize { reads += 1 }
            rescue => error
              mutex.synchronize { read_errors << error.message }
            end
          end
        end
      end

      # Single writer: sequential saves keep git merge --ff-only continuously
      # rewriting the working-tree events.json that the readers are reading.
      150.times do
        kata_ran_tests(id, next_index, files, stdout, stderr, 0, red_summary)
        next_index += 1
      end

      mutex.synchronize { stop = true }
      readers.each(&:join)

      diagnostic = "reads=#{reads}, read_errors=#{read_errors.size}\n#{read_errors.uniq.join("\n")}"
      assert_equal [], read_errors, diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Absolute path of a kata's working-tree events.json, e.g.
  # /cyber-dojo/katas/Sy/G9/sT/events.json (same layout as
  # assert_tag_commit_message in test_base.rb).
  def events_json_path(id)
    "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/events.json"
  end

end
