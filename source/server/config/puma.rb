#!/usr/bin/env puma

require 'etc'

environment 'production'
rackup "#{__dir__}/config.ru"

# Each POST write builds its commit in-process (libgit2 via the rugged gem) and
# advances the main branch to it with a git update-ref compare-and-swap
# (kata_v2.rb; see docs/in-process-git.md). If two concurrent writes target the
# same kata, only one CAS will succeed; the loser rebuilds on the new head and
# re-appends (a test-family write) or is dropped as superseded (a file event).
# The saver assigns each event's position (head + 1) and does not reject a write
# for a stale client index; mobbing detection lives in the browser's read-side
# poll.
#
# GET requests always see a consistent committed state because all writes are
# atomic at the git level.
#
# The test KataConcurrentSavesTest#DccG02 reproduces the concurrent-write race
# and confirms every save commits, at contiguous indices.

workers Etc.nprocessors
