require_relative 'test_base'

class KataTornReadTest < TestBase

  version_test 2, 'Tn6Wb1', %w(
  | events() reads committed state through git, not the working tree, so a
  | partial working-tree events.json (the torn-read window during a save's
  | git merge --ff-only) does not affect the read. Truncating the working-tree
  | events.json leaves kata_events returning the committed events unchanged.
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => '', 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

      expected = kata_events(id)

      path = working_tree_path(id, 'events.json')
      full = File.read(path)
      # Simulate a partial chunked write: only a prefix has landed.
      File.write(path, full[0, full.size / 2])

      assert_equal expected, kata_events(id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb2', %w(
  | events() reads committed state through git, not the working tree, so an
  | absent working-tree events.json (the ENOENT window during a save's
  | git merge --ff-only) does not affect the read. Deleting the working-tree
  | events.json leaves kata_events returning the committed events unchanged.
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => '', 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

      expected = kata_events(id)

      File.delete(working_tree_path(id, 'events.json'))

      assert_equal expected, kata_events(id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Tn6Wb3 is a slow (~190 sequential git saves), timing-dependent live
  # demonstration of the torn read. It passes now that events() reads via git,
  # but it is commented out of routine suite runs: it is heavy and not a
  # reliable guard (the deterministic Tn6Wb1/Tn6Wb2 above are). Re-enable by
  # removing the =begin/=end around it.
=begin
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
=end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Absolute path of a file in a kata's working tree, e.g.
  # /cyber-dojo/katas/Sy/G9/sT/events.json (same layout as
  # assert_tag_commit_message in test_base.rb).
  def working_tree_path(id, filename)
    "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/#{filename}"
  end

end
