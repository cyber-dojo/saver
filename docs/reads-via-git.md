
Reads via git (read committed state via git, not the working tree)
==================================================================

A design note born from investigating concurrent read/write races in v2 katas.
Parts are now implemented; see "Current status and decisions" below for what is
done, what was decided against, and what remains. The rest of the note keeps the
original reasoning.


- - - -
## Current status and decisions

Done (all of it):
- The torn-read fix. events.json, options.json, and the worktree_commit
  out-of-order rescue now read committed state via `git show HEAD:<file>`
  instead of the working tree (the A/C/E conversions in the enumeration). The
  race is fixed and verified.
- Version dispatch. `Model#kata` derives a v2 kata's version from the presence
  of its `.git` dir (a cheap stat) instead of reading manifest.json, with a
  legacy manifest fallback that asserts v0/v1. (`Model#group` is unchanged: v2
  groups are not git repos.)
- download. Builds the tgz from a `git clone` of committed state (full history,
  tags, fresh HEAD checkout), not a `tar` of the working tree, so it is correct
  even when the working tree is stale.
- The write speedup. A save advances `main` with a `git update-ref`
  compare-and-swap (`fast_forward_main_via_worktree`) instead of
  `git merge --ff-only`, so it no longer checks the new tree out; the working
  tree is left stale. The CAS preserves loser-detection (a concurrent save
  whose base moved fails and resolves to "Out of order event").

Decided against: making the kata repo bare. A bare repo is a different on-disk
layout, so it would be a de-facto new format (v3) and a population of mixed
bare/non-bare v2 dirs. We do not want that.

End-state (now in place): the repo stays NON-bare, but saves no longer refresh
its working tree; they advance `main` with `git update-ref`, leaving the working
tree stale. A stale working tree is harmless because every read of current data
goes through git. No bare repo, no v3.

manifest.json stays a working-tree read: it is written once at create() and
never rewritten, so it is immutable and a stale working-tree copy is still
correct. No manifest conversion was needed.

Remaining work: none. The reads-via-git conversions (events, options, rescue,
download), the `.git` version dispatch, and the `update-ref` write speedup are
all in place. The sections below record the original problem and reasoning.


- - - -
## Background: how a v2 kata stores and reads data

A v2 kata is a git repo (`source/server/model/kata_v2.rb`). Two kinds of access
touch the same files:

- Writes go through git. A save commits the new event into a throwaway
  `/tmp/<branch>` worktree, then fast-forwards `main` into it with
  `git merge --ff-only` (`worktree_commit`, kata_v2.rb:389-478, merge at :533).
  Concurrency between two writers is resolved entirely at this git layer: the
  loser of the merge race is caught and reported as "Out of order event". There
  is no flock anywhere; per-kata flock was removed (PRs #377-#380) to cut
  per-request overhead.

- Reads go straight to the working tree on disk. `read_events`, `read_manifest`
  and `read_options` (kata_v2.rb:543-560) read `events.json`, `manifest.json`
  and `options.json` with a plain `File.open(RDONLY).read`
  (`External::Disk#file_read`, disk.rb:85-94).

So `git merge --ff-only` does two things at once: it advances the `main` ref AND
it refreshes the main repo's working-tree copies of those files. Reads depend on
that working-tree refresh having landed cleanly.


- - - -
## The artifact this note is about

The main repo keeps a checked-out working tree for one reason only: so the
plain-file reads above have something to read. No writer needs it. Every write
is composed in a separate `/tmp` worktree and only merged in.

That makes the main working tree a read-only convenience that the writer must
nonetheless keep re-materialising on every save. It is the shared, mutable
artifact that the reader and the writer collide on.


- - - -
## The race it creates

A reader that runs while a save's `git merge --ff-only` is refreshing the
working tree can observe `events.json` (or `manifest.json` / `options.json`)
part-written or momentarily absent. `file_read` then returns partial bytes
(so `json_parse` raises) or `false` (so `assert` raises
"command != true ... No such file or directory", disk_api.rb:35-43). Either way
the read surfaces as a raw diagnostic instead of resolving cleanly.

This is the same family of bug as the already-fixed "git archive over the
tag-write window" race (`git_archive`, kata_v2.rb:498-511): a reader observing
an in-between state of a save. The archive fix retries around its window. The
working-tree reads have no such guard, because they do not go through git at
all.


- - - -
## The framing: read through git, stop refreshing the working tree

Rather than retry around torn working-tree reads (reading around the race),
remove the racy artifact:

1. Read committed state through git instead of off the working tree. For the
   current snapshot, read at the branch tip, e.g.

       git show <sha>:events.json

   A branch advance is an atomic ref update, and the blob/tree/commit objects a
   commit points at are written into the object store before the ref is moved
   (the save commits in its `/tmp` worktree first, then fast-forwards). So a
   read resolved against a committed object always sees a whole, consistent
   file: either the pre-merge or the post-merge content, never a partial one,
   never a missing one. The torn-read window cannot exist because there is no
   working-tree file in the read path to catch mid-rewrite.

2. Once nothing reads the working tree, the writer no longer needs to refresh
   it. Advancing `main` with `git update-ref` (instead of `git merge --ff-only`)
   moves the ref without checking the new tree out (the commit already exists in
   the object store via the `/tmp` worktree). The repo stays NON-bare; its
   working tree just goes stale. We deliberately do NOT go fully bare: that would
   change the on-disk layout into a de-facto v3 (see the status section above).

Step 2 is what distinguishes this from "just read via git." Reading via git
fixes the symptom; not refreshing the working tree removes the shared mutable
file that caused it, and removes the per-save checkout cost that was only ever
there to feed the old read path.


- - - -
## Get a snapshot, not N independent reads

This concern turned out to be moot. It would matter only if two *mutable* files
were read via git and had to agree. After the conversions, the only mutable
files read via git are `events.json` and `options.json`, and no operation reads
both via git as a pair: `manifest()` reads `manifest.json` from the working tree
(immutable) and `options.json` via git, so there is no multi-file git snapshot
to coordinate.

(Kept for the record: if a future change ever read two mutable files via git
together, it should resolve one sha once and read both at it, e.g.
`sha = git rev-parse HEAD` then `git show <sha>:a` / `git show <sha>:b`, rather
than two independent `git show HEAD:` calls that could straddle a concurrent
save.)


- - - -
## What this does NOT change

- The numeric-tag-lags-merge race is separate and still needs its own fix.
  Reads that address a *specific historical* index (not the tip) resolve it by
  its numeric git tag, and `git tag <index> HEAD` is still written as a separate
  step after the merge (kata_v2.rb:378). The `git_archive` retry stays
  necessary. This note is only about the latest-snapshot reads that currently
  hit the working tree.

- The write path and its concurrency handling are unchanged. The "Out of order
  event" detection at the merge layer still does the work it does now.


- - - -
## Knock-on: potential speedups for writes

Moving reads off the working tree does not only fix a race. It removes work the
write path currently does solely to keep that working tree readable.

The change: drop the working-tree refresh from every save. The old
`git merge --ff-only` advanced `main` AND checked the new tree out into the main
repo's working dir. The checkout half existed only so the working-tree files
could be read; once nothing reads them it is waste, so the advance becomes a
ref-only update:

    git update-ref refs/heads/main <branch> <branch>^

The commit already exists in the shared object store (it was built in the
`/tmp` worktree), so moving the ref is all that is logically required.

Magnitude (unmeasured, and not a clear-cut win). The refresh re-writes the files
that changed in the commit -- `events.json` plus the small metadata files
(`stdout`/`stderr`/`status`/`truncations.json`); unchanged `files/` are not
re-written. Those are small writes, except `events.json`, which grows with the
session. But the dominant per-save cost is git process startup, not this file
I/O, and the advance is still one git subprocess either way (merge, vs
update-ref with `branch^` as the CAS old-value). So skipping the checkout is a
real saving mainly when `events.json` is large (long sessions); for small katas
it may be a wash. This has not been benchmarked -- the honest claim is "removes
the per-save working-tree checkout", not "measurably faster". The torn-read fix
(reads-via-git) stands on its own correctness merits regardless.

A bonus: cheaper, more precise concurrency detection. Write/write concurrency is
caught today by `git merge --ff-only` failing on a non-fast-forward, then the
rescue re-reading `events.json` to decide "Out of order event"
(kata_v2.rb:472-477). A compare-and-swap ref update,

    git update-ref refs/heads/main <new-sha> <expected-old-sha>

fails atomically if `main` moved since the writer read it, which is exactly the
loser-detection, without a checkout. So this could also replace the
merge-plus-rescue dance with something both faster and more precise.

What does NOT get faster:

- The `/tmp` worktree checkout stays. `git worktree add` (kata_v2.rb:530)
  materialises a full tree so the writer can `git rm`, rewrite `files/`, and
  commit. That is the write/write concurrency mechanism (two writers on separate
  branches off the same HEAD), independent of how reads work. Removing it would
  mean building commits with plumbing (`hash-object` / `update-index` /
  `commit-tree`), a separate and bigger change not unlocked by moving reads.
- The tag write (`git tag <index> HEAD`, kata_v2.rb:378) is unchanged.
- Secondary and indirect: less disk I/O and page-cache churn per save, and less
  read/write disk contention under concurrency. Real but unmeasured.

Confidence note: the git semantics here (`update-ref` advancing a branch on a
non-bare repo and leaving the working tree stale, `update-ref` compare-and-swap,
`merge` needing a working tree) are reasonably certain but have not been
re-verified from git source in this work.


- - - -
## Trade-offs and open questions

- Cost moves, it does not vanish. Each read becomes a git subprocess
  (`assert_cd_exec`) instead of a cheap `File.read`. `events()` / `event()` /
  `file_edit()` read `events.json` on a hot path. Against that: the per-save
  working-tree checkout disappears, and writes already shell out to git heavily.
  Whether the net is a win needs measuring, not assuming, and runs against the
  overhead-cutting direction of #377-#380.

- Stopping the working-tree refresh (the stale-tree switch) requires that
  nothing reads it for current data. `download` (kata_v2.rb:308-321) is the
  holdout: it `tar`s the repo dir to ship the kata as a real git repo the user
  can push to GitHub (the generated README literally instructs `git push`), so a
  stale tree would ship stale content. It must move to git first. See the
  download conversion note in the enumeration below for why `git archive` does
  NOT work here.

- Where we are now is the safe intermediate state: the working tree is still
  refreshed by `git merge --ff-only`, but the reads that need current data go
  through git, so nothing depends on the refresh except `download`. The
  stale-tree switch (`update-ref` instead of `merge --ff-only`) is the next step
  once `download` is converted; it is reversible and needs no layout change.


- - - -
## Verification: git's working-tree write is non-atomic (confirmed)

Resolved. The open question was whether `git merge --ff-only` refreshes a
working-tree file atomically enough that a concurrent reader cannot tear. It
does not.

An `strace` of `git merge --ff-only` modifying a tracked file (git 2.45.4 on
Alpine/musl, the same distro and libc family as the production `sinatra-base`
image, which installs git via `apk add git`) showed this sequence on the
working-tree path:

    unlinkat(..., "target.txt", 0) = 0                      # remove existing file
    openat(..., "target.txt", O_WRONLY|O_CREAT|O_EXCL ...)  # recreate fresh
    write(..., 16384) x13                                   # write new content in 16 KB chunks

So the strategy is unlink, then create with `O_EXCL`, then write in chunks. It
is NOT atomic temp+rename (no `rename` touches the path; only `.git/` lockfiles
are renamed) and NOT in-place `O_TRUNC`. The `O_EXCL` flag is why the file must
be unlinked first.

Both windows the rest of this note assumes are therefore real for a reader whose
`File.open(RDONLY)` lands inside them:

- ENOENT window: between the `unlinkat` and the `openat O_CREAT` the path does
  not exist, so `file_read` returns `false` (disk.rb:90-93) and `assert` raises
  "command != true ... No such file or directory" (disk_api.rb:35-43).
- Torn-read window: after the create and during the chunked writes, the reader
  sees a byte prefix of the new file, so `json_parse` raises on truncated JSON.

(A reader that opens before the `unlinkat` is safe: its fd stays pinned to the
original inode and reads the complete old content. Only opens that land inside
the two windows tear.)

This confirms the race is real, not hypothetical, and that the framing removes a
genuine race rather than re-plumbing reads on a hunch. The trace used git
2.45.4; the unlink-create-write strategy in git's `write_entry` has been stable
across versions, but if a specific production git version matters it is worth
re-running the trace against that exact build.

Three lines of evidence now agree:

- The strace above (the mechanism).
- Deterministic server tests `test/server/kata_torn_read.rb` (`Tn6Wb1`,
  `Tn6Wb2`): each window reproduced in isolation by corrupting/removing the
  working-tree events.json, asserting the current raw error. Reliable, not
  timing-dependent.
- A live in-process concurrent test (`Tn6Wb3`): one writer thread streaming
  saves while reader threads hammer `kata_events`. A run caught the torn read
  under real threading: 34 raw read failures out of 91,091 reads (~0.04%),
  showing BOTH windows: "No such file or directory" (the unlink/create gap) and
  JSON "unexpected end of input at line 1 column 1" (the create-before-first-
  write instant, i.e. a zero-byte file). Timing-dependent, so it is a
  demonstration, not a guarantee; the deterministic tests are the proof.


- - - -
## Sequencing and rollout

There is a hard ordering dependency: the write speedup (advancing `main` with
`update-ref` instead of `merge --ff-only`, leaving the working tree stale) is
unsafe until nothing reads the working tree for current data.

Step 1 (DONE): move the reads of mutable data through git -- `events.json` (A),
`options.json` (C), and the rescue read (E). This fixes the torn-read race on
its own, independently of the write speedup.

Step 2 (DONE): convert `download` to read from git (a `git clone`), since its
`tar` of the working tree would otherwise ship stale content after the switch.

Step 3 (DONE): the write speedup -- replace `merge --ff-only` with the
`update-ref` CAS advance, leaving the working tree unrefreshed.

What does NOT need converting:
- `manifest.json` reads (`read_manifest`): immutable, so a stale working-tree
  copy stays correct. Stays a working-tree read.
- version dispatch: was a manifest read on every kata operation; sped up
  separately by detecting the `.git` dir (see the status section), so it no
  longer reads `manifest.json` for v2 katas.

So the stale-tree switch needs only events/options/rescue (done) plus `download`
(step 2) -- NOT "every working-tree read", and no bare repo.

Cost note: reads of mutable data become git subprocesses instead of `File.read`;
the payoff (skipping the per-save checkout) arrives with the write speedup. So
the two are best planned together rather than stopping after step 1.


- - - -
## Enumeration: working-tree reads in kata_v2

Every read primitive (`read_events` / `read_options` / `read_manifest` ->
`read_json` -> `read` -> `disk.file_read_command`) and every shell command that
touches a tree, classified by which tree it reads. Only reads of the main repo
working tree of *mutable* data are broken by the stale-tree switch.

Reads of the main working tree, split by whether the file can actually tear (a
save rewrites it, so a concurrent reader can be caught in the git merge --ff-only
rewrite window) or is immutable.

Torn-read reads, to convert (the file is rewritten by a save):

- A. `events(id)`, kata_v2.rb:99 reads `events.json` (rewritten every save).
  DONE: now reads via `git show HEAD:events.json` (`read_events_via_git` /
  `git_show`). Hot path: directly, plus `event()`, `event_batch()`, and every
  save method through `file_edit()`.
- C. `option_get(id, name)`, kata_v2.rb:283 (`read_options(disk, id)`) reads
  `options.json` (rewritten by `option_set`). Reached by the `option_get`
  endpoint, the per-option loop in `manifest()`, and the guard in `option_set`.
- E. `worktree_commit` rescue, kata_v2.rb:473 (`read_events(disk, id)`) reads
  `events.json` on the error path of every save. It wants the tip (latest
  committed) to decide "out of order", not a snapshot.

Convert A, C, E by reading at `HEAD` (`git show HEAD:<file>`). Each reads a
single file, so no multi-file snapshot is needed; `HEAD` advances atomically on
the ff-merge and always resolves, so no retry (unlike the numeric tags).

Immutable or already handled. Not part of the torn-read fix, and (except
download) not needed for the stale-tree switch either:

- B. `manifest(id)`, kata_v2.rb:88 (`read_manifest(id)`) reads `manifest.json`.
  manifest.json is written once by `create()` and never rewritten (saves rewrite
  events.json and metadata; `option_set` rewrites options.json), so it is
  immutable: it cannot tear, and a stale working-tree copy stays correct. So it
  STAYS a working-tree read -- no conversion needed, now or for the stale-tree
  switch.
- Version dispatch (`Model#kata`, model.rb): RESOLVED separately. It used to read
  `manifest.json` on every kata operation just to get the version; it now detects
  the `.git` dir (=> v2) with a legacy `manifest.json` fallback that asserts
  v0/v1. So this is no longer a manifest read for v2 katas. (`Model#group` still
  reads its manifest; v2 groups are flat files, outside this scope.)
- D. `download(id)` (DONE): formerly `tar`ed the working tree; now `git clone`s
  the repo into a temp dir (full history, tags, fresh HEAD checkout), removes
  the local-path origin, and `tar`s the clone, so it works with a stale working
  tree. NOT a `git archive` swap: `git archive` emits only the tree at a commit,
  with no `.git` and no history, but download's contract is to ship the whole
  repo with history so the user can push it to GitHub. The test `kata_download.rb`
  (kL375s) pins that (asserts the unpacked tgz has a working `.git`, the right
  tags, full commit history, commit<->tag correspondence, and a clean HEAD
  checkout); kL375v pins independence from a corrupt working tree. A naive
  `git archive` would fail kL375s.

Reads that are NOT of the main working tree (no conversion needed for the race):

- F. `option_set`, kata_v2.rb:296 (`read_options(worktree)`) reads the
  `/tmp/<branch>` `options.json`. Private worktree, freshly checked out by this
  save; not shared.
- G. `worktree_commit`, kata_v2.rb:410 (`read_events(worktree)`) reads the
  `/tmp/<branch>` `events.json`. Same private worktree.
- H. `worktree_commit`, kata_v2.rb:428 (`git diff #{index-1} --staged`) reads
  the `/tmp/<branch>` index and the tag's tree. Runs in the private worktree;
  also a diff (out of scope).
- I. `git_archive`, kata_v2.rb:502 (`git archive #{pos_index}`) reads the git
  object store via tag. Already a git read, not a working-tree read; this is the
  model from the recent tag-window fix.
- J. `download`, kata_v2.rb:319 (`File.read(tgz_file_path)`) reads the freshly
  produced `.tgz` in `Dir.mktmpdir`, i.e. tar's own output, not the kata tree.

Note: F and G read the `/tmp/<branch>` worktree created by `git worktree add`
(:530), which stays checked out for the save's duration. The stale-tree switch
only stops refreshing the *main* working tree, so it does not affect F and G.
Of the main-tree reads, only events/options/rescue (A, C, E -- done) and
`download` (D) ever needed converting.
