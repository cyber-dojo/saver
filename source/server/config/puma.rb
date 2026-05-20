#!/usr/bin/env puma

environment 'production'
rackup "#{__dir__}/config.ru"

# Do NOT set workers > 1.
#
# The server serialises concurrent writes to the same kata using
# post_json_with_mutex (app_base.rb), which holds a per-kata Ruby Mutex
# for the entire duration of each write request. This prevents a second
# write to the same kata from interleaving with the first (e.g. two
# concurrent kata_ran_tests calls whose git_ff_merge_worktree sequences
# would otherwise overlap and cause an 'Out of order event' error).
#
# A Ruby Mutex is in-process state. With workers > 1, Puma forks N
# separate OS processes, each with its own independent copy of every
# mutex. Two concurrent writes to the same kata can land in different
# worker processes, each acquiring its own per-kata mutex without
# knowledge of the other, and the race condition returns.
#
# The test KataConcurrentSavesTest#DccG02 reproduces this race reliably
# and will fail when workers > 1.
#
# Fixing this properly would require replacing the in-process mutex with
# a cross-process lock (e.g. a file lock) so that all workers compete on
# the same lock for a given kata ID.
