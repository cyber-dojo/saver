
Reads via git (make git the sole read path)
============================================

A design note, not a description of current behaviour. It records a framing
that came out of investigating concurrent read/write races in v2 katas, so the
reasoning is not lost. Nothing here is implemented yet.


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
   it. The fast-forward of `main` can move the ref without checking the new tree
   out into the main repo (the commit still exists in the object store via the
   `/tmp` worktree). The main repo effectively becomes bare for the data files.

Step 2 is what distinguishes this from "just read via git." Reading via git
fixes the symptom; not refreshing the working tree removes the shared mutable
file that caused it, and removes the per-save checkout cost that was only ever
there to feed the old read path.


- - - -
## Get a snapshot, not N independent reads

`manifest(id)` (kata_v2.rb:87-94) reads `manifest.json` and then, per option,
`options.json` as separate reads. If each were its own `git show HEAD:...`,
HEAD could advance between them and compose files from two different commits.

So a read that spans more than one file must resolve the commit once and read
every file relative to that one sha:

    sha = git rev-parse HEAD      # or refs/heads/main
    git show <sha>:manifest.json
    git show <sha>:options.json

This gives a real point-in-time snapshot. (Today the practical exposure is
narrow because `worktree_commit` does not rewrite `manifest.json`; only
`option_set` rewrites `options.json`. But the snapshot rule is the correct shape
regardless.)


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

The direct win: drop the working-tree refresh from every save. Today
`git merge --ff-only <branch>` (kata_v2.rb:533) advances `main` AND checks the
new tree out into the main repo's working dir. The checkout half exists only so
the working-tree files can be read. If nothing reads them, it is pure waste, and
the fast-forward can become a ref-only advance:

    git update-ref refs/heads/main <branch-sha>

The commit already exists in the shared object store (it was built in the
`/tmp` worktree), so moving the ref is all that is logically required.

Magnitude: the working-tree refresh writes every file in the kata tree to disk,
including `events.json`, which grows with the number of events. Late in a long
session every save rewrites an ever-larger `events.json` into the main working
tree on top of having already written it once in the `/tmp` worktree. Skipping
the refresh roughly halves the per-save file-write work, and the saving grows
with session length.

A bonus: cheaper, more precise concurrency detection. Write/write concurrency is
caught today by `git merge --ff-only` failing on a non-fast-forward, then the
rescue re-reading `events.json` to decide "Out of order event"
(kata_v2.rb:472-477). A compare-and-swap ref update,

    git update-ref refs/heads/main <new-sha> <expected-old-sha>

fails atomically if `main` moved since the writer read it, which is exactly the
loser-detection, without a checkout. So removing the working tree could also
replace the merge-plus-rescue dance with something both faster and more precise.

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

Confidence note: the git semantics here (bare-repo ref moves, `update-ref`
compare-and-swap, `merge` needing a working tree) are reasonably certain but have
not been re-verified from git source in this work.


- - - -
## Trade-offs and open questions

- Cost moves, it does not vanish. Each read becomes a git subprocess
  (`assert_cd_exec`) instead of a cheap `File.read`. `events()` / `event()` /
  `file_edit()` read `events.json` on a hot path. Against that: the per-save
  working-tree checkout disappears, and writes already shell out to git heavily.
  Whether the net is a win needs measuring, not assuming, and runs against the
  overhead-cutting direction of #377-#380.

- Making the main repo bare-for-data is a larger change than swapping the read
  calls. Anything that assumes a populated working tree must be checked.
  `download` (kata_v2.rb:308-321) is the awkward one: it `tar`s the repo dir to
  ship the kata as a real git repo the user can push to GitHub (the generated
  README literally instructs `git push`). See the download conversion note in
  the enumeration below for why `git archive` does NOT work here.

- An intermediate option exists: keep the working tree but read via git anyway.
  That fixes the torn read without the bare-repo work, at the cost of leaving
  the now-pointless per-save checkout in place. It is a smaller, reversible
  first step toward the full framing.


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

The two changes have a hard ordering dependency, not just a preferred order:
the write speedup (ref-only advance, dropping the main-tree checkout) is unsafe
until nothing reads the working tree. So reads-via-git is the step that unlocks
the write change, and must land first.

Step 1: move all reads through git.
- Independently valuable: it fixes the torn-read race on its own, whether or not
  step 2 ever happens.
- The intermediate state is safe and shippable: the ff-merge still refreshes the
  main working tree, but nothing reads it, so the refresh is harmless waste. The
  work can pause here indefinitely.
- Verifiable in isolation: read correctness can be confirmed before the write
  path is touched at all.

Step 2: stop refreshing the main working tree (ref-only advance, the write
speedup above). Safe only once step 1 guarantees no reader depends on the
working tree.

Caveats to hold onto:

- "All reads" must mean all of them, or step 2 breaks. The full enumeration is
  in the next section. For the torn-read fix only the reads of files a save
  actually rewrites need converting (events.json and options.json); the manifest
  reads are immutable and the download read is special, so they ride with step
  2. For step 2 (bare repo) every working-tree read must move to git.

- Step 1 alone is a net cost. Reads become git subprocesses (slower per read);
  the payoff (faster writes) only arrives in step 2. Shipping step 1 and
  stopping trades read latency for correctness. That is a fine trade if the race
  is real, but it means the two steps are best planned together rather than
  step 1 shipped and forgotten.


- - - -
## Enumeration: working-tree reads in kata_v2

Every read primitive (`read_events` / `read_options` / `read_manifest` ->
`read_json` -> `read` -> `disk.file_read_command`) and every shell command that
touches a tree, classified by which tree it reads. Only reads of the main repo
working tree are the shared racy artifact that step 2 (making main bare) would
break.

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

Immutable, or deferred to step 2 (bare repo). Not part of the torn-read fix:

- B. `manifest(id)`, kata_v2.rb:88 (`read_manifest(id)`) reads `manifest.json`.
  manifest.json is written once by `create()` and never rewritten (saves rewrite
  events.json and metadata; `option_set` rewrites options.json), so it is
  immutable and a save's ff-merge never refreshes it. It cannot tear, so it does
  not need reading via git for correctness; only the bare-repo goal needs it.
- `from_path` (model.rb:180), MISSED by this kata_v2-scoped enumeration:
  `Model#kata` and `Model#group` read manifest.json from the working tree to
  dispatch on version, before any Kata_vN is instantiated, on every operation.
  Also immutable (no torn risk), but version-agnostic: v0/v1 katas have no git
  repo, so this read cannot uniformly use `git show`. Converting it belongs with
  step 2, where the v0/v1 dispatch has to be designed.
- D. `download(id)`, kata_v2.rb:316 (`tar -czf ... .` in `repo_dir`) reads the
  whole working tree. NOT a `git archive` swap: `git archive` emits only the
  tree at a commit, with no `.git` and no history, but download's contract is to
  ship the whole repo with history so the user can push it to GitHub. The
  existing test `kata_download.rb` (kL375s) pins that (asserts the unpacked tgz
  contains a working `.git`, `git tag`, `git log`); a naive `git archive` would
  fail it. Under a bare main, download must reconstruct a pushable repo another
  way (tar the bare repo's `.git`, or `git clone` it into a temp dir and tar
  that).

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

Wrinkle for step 2: F and G read the `/tmp/<branch>` worktree created by
`git worktree add` (:530), which stays checked out for the save's duration.
Making the main repo bare does not affect them, so step 2 is safe for F and G as
written. Only A through E need to move off the main working tree.
