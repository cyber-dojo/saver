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

Removed dead routes (branch `remove-dead-routes`, merged as #336)
Removed the three stale `kata_ran_tests2 / predicted_right2 / predicted_wrong2` POST routes from `source/server/app.rb`.

---

## Fixes applied

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

## Session 2 — closing the two-commit gap in `file_rename` and similar operations

### Diagnosis

Fix 4 (a per-call mutex in `git_ff_merge_worktree`) would serialise individual git commits but not entire HTTP requests. Some operations call `git_ff_merge_worktree` twice in sequence:

- `file_rename` — calls `file_edit` (1st ff-merge) then the rename commit (2nd ff-merge)
- `ran_tests`, `predicted_right`, `predicted_wrong`, `reverted`, `checked_out` — all call `file_edit` then `git_commit_tag_sss`

Between the two calls the mutex is released. A competing Puma thread can acquire it, commit at the index the first thread was about to use, and cause the first thread's second commit to raise `'Out of order event'`.

### Reproducing the bug — `test/client/kata_concurrent_saves_test.rb` (DccG02)

`thread_a` calls `kata_ran_tests(id, 1, large_files, ...)`. Its `file_edit` makes a large commit (slow, holding the mutex longer) then releases. `thread_a`'s second ff-merge will try index=2.

100 b_threads each call `kata_ran_tests(id, 2, unique_files_i, ...)` with a unique file edit. Each b_thread's `file_edit` detects its unique change and blocks on the mutex while `thread_a` holds it. When `thread_a` releases after its first commit, one b_thread immediately acquires, commits at index=2, and `thread_a`'s second commit raises `'Out of order event'`.

`kata_ran_tests` is also added to `source/client/external/saver.rb` to make it callable from client tests.

### Fix 5 — Per-request mutex in `app_base.rb` (`post_json_with_mutex`)

The mutex is moved to the HTTP layer (per-request). `app_base.rb`:

```ruby
KATA_MUTEXES_LOCK = Mutex.new
KATA_MUTEXES = Hash.new { |h, k| h[k] = Mutex.new }

def self.post_json_with_mutex(klass_name, method_name)
  post "/#{method_name}", provides:[:json] do
    respond_to do |format|
      format.json do
        id = to_json_object(request_body)['id']
        mutex = AppBase::KATA_MUTEXES_LOCK.synchronize { AppBase::KATA_MUTEXES[id] }
        mutex.synchronize do
          json_result(klass_name, method_name)
        end
      end
    end
  end
end
```

All kata state-mutating POST routes in `app.rb` are switched from `post_json` to `post_json_with_mutex`. The mutex is keyed on `id`, so the entire HTTP request — however many `git_ff_merge_worktree` calls it makes — is atomic with respect to other requests for the same kata.

