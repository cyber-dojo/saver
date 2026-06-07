#!/usr/bin/env puma

require 'etc'

environment 'production'
rackup "#{__dir__}/config.ru"

# Each POST write happens inside a git worktree, then advances the main branch
# to it with a git update-ref compare-and-swap (kata_v2.rb). If two concurrent
# writes target the same kata, only one CAS will succeed; the other fails and is
# detected as an 'Out of order event' error, which the web layer treats as an
# out-of-sync condition and shows a dialog.
#
# GET requests always see a consistent committed state because all writes are
# atomic at the git level.
#
# The test KataConcurrentSavesTest#DccG02 reproduces the concurrent-write
# race and confirms exactly one save succeeds while the rest raise
# 'Out of order event'.

workers Etc.nprocessors
