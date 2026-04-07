A cyber-dojo user reported losing traffic lights even when working alone (no competing submissions from a second browser). This file records the investigation and fixes applied.

---

## Investigation

### Code reviewed

- `source/server/model/kata_v2.rb` — main v2 save logic, git worktree usage
- `source/server/external/shell.rb` — shell command execution and stderr handling
- `source/server/app.rb` — HTTP route registration
- `source/server/model.rb` — model method dispatch
- `../web` repo — how the browser calls the saver API

### How saves work in v2

Every save (file edit, test run, etc.) goes through `git_ff_merge_worktree`:

1. A random 8-char branch name is generated.
2. `git worktree add /tmp/<branch>` creates an isolated working copy checked out on that branch.
3. The caller commits its changes inside that worktree.
4. `git merge --ff-only <branch>` fast-forwards the main repo HEAD to the new commit.
5. An `ensure` block cleans up the worktree, branch, and tmp directory.
6. Back in `git_commit_tag_sss`, a numeric git tag matching the event index is applied to HEAD.

Each event index corresponds to a git tag. Later reads use `git archive --format=tar <index>` to retrieve the state at that event.

### Findings

#### Bug 1 (minor risk for solo user): No mutex around `git_ff_merge_worktree`

Both `git_commit_tag_sss` (every save) and `option_set` call `git_ff_merge_worktree` with no per-kata serialisation. If Puma processes two requests for the same kata concurrently, both create worktrees from the same HEAD, both commit, but only the first `git merge --ff-only` succeeds. The second fails because HEAD has moved — it is no longer a fast-forward. The second save is lost.

Investigation of the `../web` repo showed that **all saver calls from the web service are synchronous and sequential** — the browser never sends two requests for the same kata simultaneously. Settings calls use `async: false`; file-event calls use a callback chain; test runs wait for completion before doing anything else. So this race cannot currently be triggered by the web service, and is not the cause of the user's problem. It remains a latent risk if the web service ever changes.

#### Bug 2 (most likely cause): `ensure` block raises and suppresses a successful merge

`kata_v2.rb:455-460`:

```ruby
ensure
  shell.assert_cd_exec(repo_dir,        # raises if anything goes wrong
    "git worktree remove --force #{branch}",
    "git branch --delete --force #{branch}",
    "rm -rf #{worktree_dir}"
  )
end
```

`assert_cd_exec` raises on any failure. In Ruby, an exception raised inside an `ensure` block propagates out of the method even if the body completed successfully. So if the cleanup fails — even after `git merge --ff-only` already succeeded and the data is safely committed — the exception escapes `git_ff_merge_worktree`, and the next line in `git_commit_tag_sss` is never reached:

```ruby
shell.assert_cd_exec(repo_dir(id), ["git tag #{index} HEAD"])
```

The commit exists in git but has no numeric tag. The next save calls `event(id, last_index)['files']`, which does `git archive --format=tar <last_index>`. With no tag for that index, this raises, and **all subsequent saves for that kata fail permanently** until manually repaired.

#### Bug 3 (hidden tripwire): `ok?` check in `shell.rb` treats stderr as failure

```ruby
def ok?(stderr)
  stderr.empty? || stderr.start_with?('Preparing worktree')
end
```

`assert_exec` raised if exit status was non-zero **or** if stderr was non-empty and did not start with `'Preparing worktree'`. Newer versions of git emit `hint:` lines and deprecation warnings to stderr on otherwise successful commands. Any such output from any cleanup command would trigger the ensure bug above, turning a successful save into a permanently broken kata.

#### Minor: stale routes in `app.rb`

`app.rb` still registered `kata_ran_tests2`, `kata_predicted_right2`, `kata_predicted_wrong2`, but these were deleted from `model.rb` in commit `0f8048e` when the web service switched to the non-`2` endpoints. If ever called they would raise `NoMethodError` → 500. Not a current cause of lost saves, but a source of confusion.

---

## Fixes applied

### Fix 1 — Remove dead routes (branch `remove-dead-routes`, merged as #336)

Removed the three stale `kata_ran_tests2 / predicted_right2 / predicted_wrong2` POST routes from `source/server/app.rb`.

### Fix 2 — Prevent `ensure` cleanup from raising (branch `ensure-worktree-cleanup-does-not-raise`, merged as #337)

Wrapped the ensure block in `git_ff_merge_worktree` with a `rescue`, so a cleanup failure is logged to stderr but never propagates:

```ruby
ensure
  begin
    shell.assert_cd_exec(repo_dir,
      "git worktree remove --force #{branch}",
      "git branch --delete --force #{branch}",
      "rm -rf #{worktree_dir}"
    )
  rescue => e
    # :nocov:
    $stderr.puts "git_ff_merge_worktree cleanup failed: #{e.message}"
    $stderr.flush
    # :nocov:
  end
end
```

### Fix 3 — Remove `ok?` stderr check (branch `remove-stderr-check`, merged as #338)

Removed the `ok?` method from `shell.rb`. Failure is now determined solely by non-zero exit status. Unexpected stderr is logged rather than treated as an error, with `'Preparing worktree'` output suppressed as it is expected and noisy:

```ruby
unless stderr.empty? || stderr.start_with?('Preparing worktree')
  # :nocov:
  $stderr.puts stderr
  $stderr.flush
  # :nocov:
end
```

`# :nocov:` markers are used on both new logging blocks because SimpleCov is configured as the coverage tool and these error paths cannot be exercised by the test suite.

---

## Remaining open question

Bug 1 (no per-kata mutex) is not currently triggerable by the web service but remains a latent risk. If the web service ever introduces asynchronous or parallel saver calls for the same kata, saves could be lost. A per-kata mutex keyed on `id` around `git_ff_merge_worktree` calls would close this permanently.

---

## Session 2 — surfacing and fixing Bug 1

### Diagnosis

A new error was reported: `"Diverging branches can't be fast-forwarded"` from `git merge --ff-only` inside `git_ff_merge_worktree`. This is the exact failure mode of Bug 1. Although the previous investigation concluded the web service was sequential, Puma's default configuration runs up to 5 threads, meaning two in-flight requests for the same kata can genuinely overlap at the server even when the browser intends them to be sequential (e.g. a `kata_option_set` and a `kata_file_edit` arriving close together).

The `REPO_MUTEXES` in `disk.rb` only protect individual file reads/writes; there was no serialisation around the git worktree create → commit → merge sequence.

### Reproducing the bug — `test/client/kata_concurrent_saves_test.rb`

Added a client-side test (`DccG01`) that creates a v2 kata and fires 6 Ruby threads concurrently, each calling `kata_option_set` for a different option (theme, colour, predict, revert_red, revert_amber, revert_green). All 6 start from their defaults so none short-circuit via the early-return check. The test asserts `errors` is empty. Without the fix it fails, confirming the race.

### Fix 4 — Per-repo mutex inside `git_ff_merge_worktree` (`kata_v2.rb`)

Added two class-level constants to `Kata_v2`:

```ruby
REPO_MUTEXES_LOCK = Mutex.new
REPO_MUTEXES = Hash.new { |h, k| h[k] = Mutex.new }
```

`REPO_MUTEXES` is a hash with a default block that lazily creates a `Mutex` per `repo_dir`. `REPO_MUTEXES_LOCK` is a single mutex that protects the hash during first-time insertion, preventing two threads from racing to create the same per-repo mutex.

`git_ff_merge_worktree` now acquires the per-repo mutex before entering the critical section:

```ruby
def git_ff_merge_worktree(repo_dir)
  mutex = REPO_MUTEXES_LOCK.synchronize { REPO_MUTEXES[repo_dir] }
  mutex.synchronize do
    branch = random.alphanumeric(8)
    worktree_dir = "/tmp/#{branch}"
    begin
      shell.assert_cd_exec(repo_dir, "git worktree add #{worktree_dir}")
      worktree = External::Disk.new(worktree_dir)
      yield worktree
      shell.assert_cd_exec(repo_dir, "git merge --ff-only #{branch}")
    ensure
      begin
        shell.assert_cd_exec(repo_dir,
          "git worktree remove --force #{branch}",
          "git branch --delete --force #{branch}",
          "rm -rf #{worktree_dir}"
        )
      rescue => e
        # :nocov:
        $stderr.puts "git_ff_merge_worktree cleanup failed: #{e.message}"
        $stderr.flush
        # :nocov:
      end
    end
  end
end
```

A second request for the same kata blocks (sleeps) until the first completes — it does not fail immediately. Read-only routes (`kata_event`, `kata_events`, etc.) are completely unaffected as they do not call `git_ff_merge_worktree`.
