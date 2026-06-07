require_relative 'test_base'
require 'fileutils'

class KataTornReadTest < TestBase

  version_test 2, 'Tn6Wb1', %w(
  | events() reads committed state through git, not the working tree, so the
  | working-tree events.json (now stale: saves no longer refresh it) does not
  | affect the read. Truncating the working-tree events.json leaves kata_events
  | returning the committed events unchanged.
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
  | absent (or stale) working-tree events.json does not affect the read.
  | Deleting the working-tree events.json leaves kata_events returning the
  | committed events unchanged.
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

  version_test 2, 'Tn6Wb4', %w(
  | option_get() reads options.json through git, not the working tree, so the
  | working-tree options.json (stale: option_set no longer refreshes it) does
  | not affect the read. Truncating the working-tree options.json leaves
  | kata_option_get returning the committed value unchanged.
  ) do
    in_kata do |id|
      expected = kata_option_get(id, 'theme')

      path = working_tree_path(id, 'options.json')
      full = File.read(path)
      File.write(path, full[0, full.size / 2])

      assert_equal expected, kata_option_get(id, 'theme')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb5', %w(
  | option_get() reads options.json through git, not the working tree, so an
  | absent (or stale) working-tree options.json does not affect the read.
  | Deleting the working-tree options.json leaves kata_option_get returning the
  | committed value unchanged.
  ) do
    in_kata do |id|
      expected = kata_option_get(id, 'theme')

      File.delete(working_tree_path(id, 'options.json'))

      assert_equal expected, kata_option_get(id, 'theme')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb6', %w(
  | The commit_event rescue decides "Out of order event" by reading the tip
  | committed events.json through git, not the working tree. The working tree is
  | stale (saves no longer refresh it), so reading it directly could mask the
  | out-of-order with a raw JSON/IO error. With a truncated working-tree
  | events.json, a stale save still reports "Out of order event".
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => '', 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

      path = working_tree_path(id, 'events.json')
      full = File.read(path)
      File.write(path, full[0, full.size / 2])

      error = assert_raises(RuntimeError) {
        kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)
      }
      assert_equal "Out of order event for #{id}", error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb7', %w(
  | As Tn6Wb6 but with the working-tree events.json absent (deleted): the
  | commit_event rescue still reports "Out of order event" because it reads
  | the tip through git rather than the missing working-tree file.
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => '', 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

      File.delete(working_tree_path(id, 'events.json'))

      error = assert_raises(RuntimeError) {
        kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)
      }
      assert_equal "Out of order event for #{id}", error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb8', %w(
  | Model#kata determines a v2 kata's version from the presence of its .git
  | directory, not by reading manifest.json. A kata operation that does not
  | itself read the manifest (kata_events reads events via git) therefore works
  | even when the working-tree manifest.json is absent, proving version dispatch
  | no longer reads it.
  ) do
    in_kata do |id|
      files  = kata_event(id, 0)['files']
      stdout = { 'content' => '', 'truncated' => false }
      stderr = { 'content' => '', 'truncated' => false }
      kata_ran_tests(id, 1, files, stdout, stderr, 0, red_summary)

      expected = kata_events(id)

      File.delete(working_tree_path(id, 'manifest.json'))

      assert_equal expected, kata_events(id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Tn6Wb9', %w(
  | kata_version only falls back to reading the manifest when there is no .git
  | dir, and a v2 kata's manifest reports version 2. So a v2 kata whose .git is
  | missing (an anomaly, not a real v0/v1) fails loudly rather than being
  | mis-dispatched as some other version.
  ) do
    in_kata do |id|
      FileUtils.rm_rf(working_tree_path(id, '.git'))

      error = assert_raises(RuntimeError) { kata_events(id) }
      assert_equal "kata #{id} has no .git but manifest version is 2", error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Tn6Wb3 is a slow (~104s: ~190 sequential git saves), timing-dependent live
  # demonstration of the torn read. A re-run after step A confirmed it now
  # reports zero torn reads (it caught 34/91,091 before events() read via git).
  # Commented out of routine suite runs: heavy, and not a reliable guard (the
  # deterministic Tn6Wb1/Tn6Wb2 are). Re-enable by removing the =begin/=end.
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

end
