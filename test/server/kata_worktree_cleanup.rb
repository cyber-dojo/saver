require_relative 'test_base'
require_relative 'doubles/shell_spy'

class KataWorktreeCleanupTest < TestBase

  version_test 2, 'Hpq7Rz', %w(
  | rm -rf of the worktree dir is its own cd_exec call, separate from the
  | git worktree remove and git branch delete calls that precede it.
  |
  | Before the fix, all three were chained with && in one assert_cd_exec.
  | When git worktree add fails partway (e.g. disk-full on /tmp), the
  | directory /tmp/<branch> is partially created but the worktree is not
  | registered with git. The cleanup then calls git worktree remove, which
  | fails because the worktree is unknown to git. The && chain stops there,
  | so rm -rf never runs and the partial directory leaks into /tmp.
  |
  | Each leaked directory consumes space, making the next git worktree add
  | more likely to fail, which leaks another directory. This cascade
  | progressively fills the 10MB /tmp tmpfs until it is completely full,
  | at which point every save attempt fails. Failed saves leave the kata's
  | numeric git tag unwritten, so the next save raises "Out of order event"
  | permanently for that kata.
  |
  | The fix gives each cleanup command its own cd_exec call (which rescues
  | internally and never raises), so rm -rf always runs regardless of
  | whether the git commands fail.
  |
  | The spy records all shell commands issued during kata_ran_tests (with
  | unchanged files). The full sequence is:
  |   [-13] ["git show HEAD:events.json"]          # file_edit -> events() (passed into event)
  |   [-12] ["git archive --format=tar 0"]         # file_edit -> event()
  |   [-11] ["git worktree add /tmp/BRANCH"]
  |   [-10] ["git rm -r files/"]
  |    [-9] ["git add ."]
  |    [-8] ["git diff 0 --staged --shortstat ..."]
  |    [-7] ["git add ."]
  |    [-6] ["git commit --message '...' --quiet"]
  |    [-5] ["git update-ref refs/heads/main BRANCH BRANCH^"]
  |    [-4] "git worktree remove --force BRANCH"   <- cd_exec
  |    [-3] "git branch --delete --force BRANCH"   <- cd_exec
  |    [-2] "rm -rf /tmp/BRANCH"                   <- cd_exec
  |    [-1] [["git tag 1 HEAD"]]
  | events.json is read via git once (file_edit reads it and passes it into
  | event(), so there is no second git show), and main is advanced by an
  | update-ref compare-and-swap rather than git merge --ff-only (no working-tree
  | checkout). The three cd_exec cleanup calls remain at positions -4, -3, -2
  | (counted from the end, so unaffected).
  ) do
    in_kata do |id|
      files   = kata_event(id, 0)['files']
      stdout  = bats['stdout']
      stderr  = bats['stderr']
      status  = bats['status']

      spy = ShellSpy.new(shell)
      externals.instance_variable_set('@shell', spy)

      kata_ran_tests(id, 1, files, stdout, stderr, status, red_summary)

      # Pin the leading reads-via-git commands so the documented sequence
      # cannot silently drift (e.g. an events read added or removed). file_edit
      # reads events.json once and passes it into event(), so there is exactly
      # one git show of events.json per save.
      assert_equal ["git show HEAD:events.json"],  spy.commands[0]
      assert_equal ["git archive --format=tar 0"], spy.commands[1]
      assert_equal 1, spy.commands.count { |c| c == ["git show HEAD:events.json"] }

      branch = spy.commands[-4].split.last
      assert_equal "git worktree remove --force #{branch}", spy.commands[-4]
      assert_equal "git branch --delete --force #{branch}", spy.commands[-3]
      assert_equal "rm -rf /tmp/#{branch}",                 spy.commands[-2]
    end
  end

end
