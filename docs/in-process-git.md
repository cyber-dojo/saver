
In-process git for the save and read hot paths (libgit2 / rugged)
=================================================================

A design note. The hot path is now IMPLEMENTED: the v2 save commit and the
events/event/options reads run in-process via libgit2 (the rugged gem), while
the diff endpoints, the concurrency ref-advance (update-ref CAS), and download
stay on the git CLI. The one remaining worktree user is kata_option_set, left on
the CLI for now (see "What landed", below). This note records the original plan,
the spike, the benchmark, and the parity findings that came out of the build.

Measured result: the server test suite dropped from ~25s to ~8s (about 3x),
matching the startup-bound prediction below.


- - - -
## The problem: per-save time is git process startup

A v2 save (kata_v2.rb) runs ~14 git subprocesses. A timing probe (5 saves on a
kata grown to ~index 10, Alpine container) measured ~298ms/save with this shape:

    git worktree add     46ms      git rm -r files/     20ms
    git add . (x2)       20ms ea   git archive          20ms
    git show events (x2) 18ms ea   git branch --delete  19ms
    git commit           33ms      git tag              19ms
    git diff --staged    21ms      git update-ref       18ms
                                   git worktree remove  14ms / rm -rf 11ms

The tell: trivial commands cost about the same as real ones. `git update-ref`
(just moves a ref) is 18ms, `git tag` 19ms, `git branch --delete` 19ms. So
~18-20ms is git's fork/exec/init floor, and only `git worktree add` (a checkout)
and `git commit` rise above it. Per-save time is roughly 14 processes times the
startup floor, not I/O.

The test suite is already parallel (`id58_test_base.rb`:
`Minitest.parallel_executor = ...Executor.new(Etc.nprocessors)`, `parallelize_me!`),
and it is dominated by this same per-op startup across hundreds of git-backed
saves and reads. So parallelism is exhausted; the only remaining lever for both
production saves and test wall-clock is to cut the per-op cost.


- - - -
## The lever: run git in-process (libgit2 via rugged)

An in-process libgit2 binding (the rugged gem) does git operations as C library
calls, with no per-op process startup. That removes the ~18-20ms floor that
dominates today. It helps production saves and, because the suite is
startup-bound and already parallel, the test wall-clock too.


- - - -
## Spike findings (rugged 1.9.0, bundled libgit2 1.9.0, Alpine)

- Builds in Alpine with its BUNDLED libgit2 in ~30s (the --use-system-libraries
  path failed against Alpine's libgit2 1.9.2 on a version mismatch). Needs
  build-base, cmake, pkgconf added to the image build.
- Commit creation, blob reads, and tree diffs all work in-process. A tree diff
  reported stat = [files, insertions, deletions], i.e. the line counts the save
  needs for diff_added_count / diff_deleted_count are available in-process.
- Gap: the atomic compare-and-swap ref update is NOT exposed by rugged's
  high-level API. `references` offers `create` (force-overwrite, not a CAS) and
  `update`, with no old-value precondition / set-target-with-expected. libgit2
  has it (git_reference_create_matching) but rugged does not surface it. That
  CAS is the whole concurrency mechanism (loser detection), so it cannot be
  dropped.


- - - -
## Reduced scope (hybrid: in-process hot path, CLI for the rest)

Move to rugged (in-process):
- create: init, config, add, commit, tag, branch.
- the save commit: build the new tree via the index (read the base tree, replace
  files/, set events.json + metadata) and Rugged::Commit.create. No
  git worktree add (no checkout), no worktree/branch/rm-rf cleanup.
- the numeric tag write (rugged ref create at refs/tags/<index>).
- the reads: events(), event() (read the needed blobs straight from the tree,
  dropping git show + git archive), options.

Keep on the git CLI (unchanged):
- the ref advance: the single
  `git update-ref refs/heads/main <new> <base>` compare-and-swap. rugged does
  not expose the CAS, and this is the concurrency primitive, so keep it as one
  shell call.
- git_diff.rb (diff_lines / diff_summary): stays exactly as it is. This removes
  the biggest parity risk (textual git-diff output parsed by git_diff_parser.rb
  vs rugged's structured deltas) from scope entirely.
- download: the git clone stays a shell call (rare; works on the repo as built).

So a save goes from ~14 git subprocesses to ~1 (the CAS) plus in-process rugged
work, and the events/event reads go from subprocess-per-call to in-process.


- - - -
## Prototype and benchmark (standalone)

A standalone prototype implemented the save both ways (shell-git worktree commit
vs the rugged hybrid: in-process index build + Rugged::Commit.create + the one
git update-ref CAS + rugged tag) and the event read both ways (git show +
git archive vs in-process blob reads), and timed them head to head. 40 saves and
100 reads each, rugged 1.9.0 in a ruby:3.3-alpine container:

    SAVES (40 each):
      shell-git :  689.1 ms total = 17.2 ms/save
      rugged    :   77.8 ms total =  1.9 ms/save     speedup 8.9x
    READS (100 each):
      shell-git :  181.9 ms total = 1.82 ms/read
      rugged    :    8.5 ms total = 0.09 ms/read     speedup 21.3x

The hybrid ran end to end: 40 sequential saves (in-process commit + the shell
CAS + rugged tag) and 100 reads all succeeded with correct commits and tags. So
the approach is functionally sound, and ~9x faster on saves, ~21x on reads.

Honest caveat on the absolute numbers: this container's git startup is ~1.6ms
per command, but the earlier in-saver probe measured ~20ms per command
(~298ms/save). So git is ~10x slower in the real saver container (Docker
storage, the `sh -c "cd ... && git"` wrapper, etc.). The RELATIVE speedup is the
robust signal; in the saver container it would be even larger, because a rugged
save there is essentially one git update-ref (~20ms) plus fast in-process work
versus ~11 subprocesses plus a checkout (~298ms). Reads become a pure in-process
win (no subprocess at all).

The benchmark used a SIMPLIFIED save (no file_edit, partial metadata, no
rename/delete cases) in a faster container, so treat the absolute ms as
indicative and the relative speedup as the finding. The decisive confirmation is
a prototype inside the saver image, run against the full server suite and
benchmarked there.


- - - -
## Why leaving diff and download on the CLI is safe

libgit2 writes the same on-disk object and ref format the git CLI reads (that
interoperability is a core libgit2 guarantee). A repo whose commits and tags
were created by rugged is an ordinary git repo, so the shell `git diff`,
`git show`, `git ls-tree`, and `git clone` in git_diff.rb and download keep
working against it unchanged. The prototype's test run confirms this concretely
(the diff suite runs its shell diffs against rugged-written commits).


- - - -
## Residual parity point: the save's own line counts (RESOLVED)

Separate from the public diff endpoints, the save computes diff_added_count /
diff_deleted_count, previously via `git diff <index-1> --staged --shortstat
--ignore-cr-at-eol`. This is now rugged's tree diff stat, and reproducing the old
counts needed two options (verified against kata_diff_added_deleted A6AE01-06,
run inside the saver image):

- `ignore_whitespace_eol: true` on `base_tree.diff(interim, ...)`. The tennis
  readme's last line has no trailing newline; appending to it changes that line's
  end-of-file newline, which the raw diff counts as an extra -1/+1 edit (so 3/1
  instead of 2/0). `--ignore-cr-at-eol` collapsed that, and so does
  ignore_whitespace_eol. (It is slightly broader than --ignore-cr-at-eol: it also
  ignores trailing-space-only changes. No save event count hinges on that, and it
  is the closest option libgit2 exposes.)
- `diff.find_similar!` before `.stat`. libgit2 does not detect renames by
  default, so a pure rename would count as a whole-file delete + add (N/N) instead
  of 0/0. The old porcelain `git diff` detected renames by default; find_similar!
  restores that.

A second parity point surfaced in the build, unrelated to diffs: the commit
MESSAGE. The old save committed via a shell command, and the two-layer
`sh -c "... git commit --message '...' ..."` quoting silently stripped the
Ruby-side quoting the message text carried (single quotes around filenames, and
the `.inspect` escaping around the reverted/checked-out JSON). With the
in-process commit the message is used literally, so those artifacts would leak
through. The fix produces the historical (clean) text directly at the source in
kata_v2.rb: `created/deleted/edited file <name>` (no quotes) and `reverted to
<json>` / `checked out <json>` (plain json_plain, not .inspect). Guarded by the
assert_tag_commit_message tests.

One more: rugged returns blob bytes tagged ASCII-8BIT. events.json is valid UTF-8
(always written via JSON.pretty_generate), so commit_on_main force_encodes it to
UTF-8 before JSON.parse; otherwise the parsed strings stay BINARY and warn (and,
under json 3.0, raise) when json_pretty re-serializes the merged events.


- - - -
## Costs and risks

- A large rewrite of the save and read paths and the create path: the
  worktree-based commit becomes index-based, git archive becomes direct blob
  reads, and the External::Shell git usage is replaced by rugged behind the same
  externals abstraction (v2 only; v0/v1 are untouched and are not git repos).
- A new heavy C-extension dependency (rugged + bundled libgit2), plus the
  image-build deps (build-base, cmake, pkgconf) and ~30s added to the image
  build.
- Behavior parity for the in-process commit/tree construction and the save's
  line counts. The strengthened save + concurrency + diff-count tests
  (Sp4DkC-G, Tn6Wb*, DccG02, Hpq7Rz, kata_diff_added_deleted) are the safety net.

What stays the same: the on-disk format, the diff endpoints' behavior, the
download contract, and the update-ref CAS concurrency semantics.


- - - -
## What landed

Implemented behind the externals abstraction (External::Git, rugged-backed),
v2 only:
- Reads: events()/event()/options read blobs straight from the tree
  (git.head_blob, git.tag_tree_blobs), replacing git show + git archive.
- Save commit: commit_event builds the new tree via the index on a single base
  (read base tree, replace files/, set events.json + metadata), computes the
  line counts via the tree diff (options above), and Rugged::Commit.create. The
  ref advance stays the one shell `git update-ref` CAS; the numeric tag is a
  rugged ref create. No git worktree add, no checkout, no worktree cleanup.

The full server suite stays green and dropped from ~25s to ~8s, confirming the
startup-bound prediction in the saver image (not just the standalone bench).

Kept on the git CLI, as planned: git_diff.rb, download, and the update-ref CAS.

Deferred (still on the CLI / worktree):
- kata_option_set still uses fast_forward_main_via_worktree (git worktree add +
  shell commit + CAS + cleanup). It is now the ONLY worktree user. Converting it
  in-process would remove fast_forward_main_via_worktree, read_options(worktree),
  and the worktree-based write_files path. Hpq7Rz (the worktree-cleanup guard) is
  now pointed at option_set, since that is the only path still creating one.
- Image build deps (build-base, cmake, pkgconf) are still left in the image;
  trim via a multi-stage build.
- git_archive is in-process now (tag_tree_blobs); the method name is stale.


- - - -
## Recommendation and rollout (DONE for the hot path)

High value (the only remaining lever for both production and test speed once
parallelism is maxed). All go/no-go gates came in green: rugged builds in Alpine,
commit/read/diff-stat work in-process, the CAS is handled by keeping the one
shell call, the standalone benchmark showed ~9x (saves) / ~21x (reads), and the
in-image full suite confirmed it end to end (~25s -> ~8s, green). The diff
endpoints can move in-process later, separately, if ever; option_set is the next
candidate if the remaining worktree machinery is worth removing.
