require 'rugged'
require 'json'

module External

  # In-process git reads via libgit2 (the rugged gem), avoiding a git subprocess
  # (~20ms of process startup) per read. Used for the latest-committed-state
  # reads (events.json, options.json) that currently shell out to
  # "git show HEAD:<file>". See docs/in-process-git.md.
  #
  # PROTOTYPE: opens the repo per call. If that proves costly, cache the
  # Rugged::Repository handle per repo_dir.
  class Git

    # Raised when the numeric tag for an index is not present yet. A save writes
    # the tag (git tag <index>) as a separate step after advancing the ref, so a
    # concurrent reader can see the new index in events.json before its tag
    # exists. The caller retries over this transient window. See git_archive in
    # kata_v2.rb and docs/in-process-git.md.
    class TagNotFound < RuntimeError; end

    # Returns the bytes of <path> in the commit HEAD points at (the kata's main
    # branch tip), as a String. Equivalent to `git show HEAD:<path>`.
    def head_blob(repo_dir, path)
      repo = Rugged::Repository.new(repo_dir)
      entry = repo.head.target.tree.path(path)
      repo.lookup(entry[:oid]).content
    end

    # Returns { path => bytes } for every blob in the tree of the commit tagged
    # <index>. Equivalent to reading `git archive --format=tar <index>`. Raises
    # TagNotFound if refs/tags/<index> does not exist yet (use the ref lookup,
    # not rev_parse, which would treat "<index>" as an ambiguous OID prefix).
    def tag_tree_blobs(repo_dir, index)
      repo = Rugged::Repository.new(repo_dir)
      ref = repo.references["refs/tags/#{index}"]
      raise TagNotFound, "no tag #{index}" if ref.nil?
      tree = repo.lookup(ref.target_id).tree
      blobs = {}
      tree.walk(:postorder) do |root, entry|
        blobs["#{root}#{entry[:name]}"] = repo.lookup(entry[:oid]).content if entry[:type] == :blob
      end
      blobs
    end

    # Builds the next commit on top of HEAD, in-process, on a single consistent
    # base (so the caller's index check and the eventual update-ref CAS both key
    # off the same base_oid). Replaces the files/ subtree with `files`
    # (name => content), computes the files/ line-count delta vs HEAD's tree, and
    # yields (base_events, added, deleted) where base_events is HEAD's
    # events.json parsed. The block returns the remaining path => content writes
    # (the new events.json, stdout/stderr/status/truncations.json); they are
    # added, the tree is written, and a commit is created (NOT advancing any
    # ref). Returns { base_oid:, new_oid: }. The caller advances main onto new_oid
    # with an update-ref compare-and-swap. See docs/in-process-git.md.
    def commit_on_main(repo_dir, message, files)
      repo = Rugged::Repository.new(repo_dir)
      base_oid = repo.head.target_id
      base_tree = repo.lookup(base_oid).tree
      base_events = read_json_blob(repo, base_tree, 'events.json')

      index = repo.index
      index.read_tree(base_tree)
      index.entries.select { |e| e[:path].start_with?('files/') }.each { |e| index.remove(e[:path]) }
      files.each { |name, content| index.add(path: "files/#{name}", oid: repo.write(content, :blob), mode: 0100644) }

      # Only files/ differs between base_tree and this interim tree, so the stat
      # is the files/ delta: [files_changed, additions, deletions]. Two diff
      # options reproduce the old `git diff --shortstat --ignore-cr-at-eol`:
      #  - ignore_whitespace_eol: collapses an end-of-file newline-only change
      #    (e.g. appending to a file whose last line had no trailing newline)
      #    just as --ignore-cr-at-eol did, so it is not miscounted as a line
      #    edit. (It also ignores other trailing-whitespace changes, which the
      #    old flag did not, but no save event hinges on that distinction.)
      #  - find_similar!: detects renames, so a pure file rename counts as 0/0
      #    rather than a whole-file delete + add, matching git's default rename
      #    detection in the old porcelain `git diff`.
      interim = repo.lookup(index.write_tree(repo))
      diff = base_tree.diff(interim, ignore_whitespace_eol: true)
      diff.find_similar!
      stat = diff.stat

      yield(base_events, stat[1], stat[2]).each do |path, content|
        index.add(path: path, oid: repo.write(content, :blob), mode: 0100644)
      end

      new_oid = Rugged::Commit.create(repo,
        tree: index.write_tree(repo), parents: [base_oid], message: message, update_ref: nil)
      { base_oid: base_oid, new_oid: new_oid }
    end

    # Creates the lightweight numeric tag refs/tags/<name> at <oid>.
    def create_tag(repo_dir, name, oid)
      Rugged::Repository.new(repo_dir).references.create("refs/tags/#{name}", oid)
    end

    # Builds a commit on top of HEAD that rewrites options.json (and nothing
    # else), in-process. Reads + parses options.json from HEAD's tree, yields it
    # for mutation, commits the writes the block returns, and returns
    # { base_oid:, new_oid: } WITHOUT advancing any ref (the caller does the
    # update-ref compare-and-swap on these oids). The simpler sibling of
    # commit_on_main: no files/, no diff, no metadata. See docs/in-process-git.md.
    def commit_options(repo_dir, message)
      repo = Rugged::Repository.new(repo_dir)
      base_oid = repo.head.target_id
      base_tree = repo.lookup(base_oid).tree
      base_options = read_json_blob(repo, base_tree, 'options.json')

      index = repo.index
      index.read_tree(base_tree)
      yield(base_options).each do |path, content|
        index.add(path: path, oid: repo.write(content, :blob), mode: 0100644)
      end

      new_oid = Rugged::Commit.create(repo,
        tree: index.write_tree(repo), parents: [base_oid], message: message, update_ref: nil)
      { base_oid: base_oid, new_oid: new_oid }
    end

    private

    # Parses <filename> from <tree> as JSON. rugged returns blob bytes tagged
    # ASCII-8BIT; our JSON files are valid UTF-8 (always written via
    # JSON.pretty_generate), so retag the bytes as UTF-8 before parsing.
    # Otherwise the parsed strings stay BINARY and warn now (and raise under
    # json 3.0) when a caller re-serializes them via json_pretty.
    def read_json_blob(repo, tree, filename)
      JSON.parse(repo.lookup(tree.path(filename)[:oid]).content.force_encoding('UTF-8'))
    end

  end

end
