#!/usr/bin/env puma

require 'etc'

environment 'production'
rackup "#{__dir__}/config.ru"

# POST requests are serialised per kata/group id via json_with_flock
# (app_base.rb), which holds an OS-level flock(LOCK_EX) on a per-id lock
# file for the entire duration of each request. This prevents two concurrent
# writes to the same kata from interleaving (e.g. two kata_ran_tests calls
# whose git_ff_merge_worktree sequences would otherwise overlap and cause an
# 'Out of order event' error).
#
# GET requests do not acquire the lock: all writes happen inside a git
# worktree and are merged back via an atomic git fast-forward, so a
# concurrent read always sees a consistent committed state.
#
# The lock is non-blocking (LOCK_EX | LOCK_NB): if a request cannot
# immediately acquire the lock it raises "Out of order event", which
# the web layer treats as an out-of-sync condition and shows a dialog.
#
# Because flock is an OS-level primitive, the lock is shared across all Puma
# worker processes: whichever worker holds the lock for a given id, every
# other worker trying to acquire the same lock will block until it is released.
# Different kata ids lock on different files and are therefore independent.
#
# The test KataConcurrentSavesTest#DccG02 reproduces the race reliably and
# confirms it does not occur with flock locking in place.

workers Etc.nprocessors
