Record the send time in the event (a client-supplied `sent_at` alongside saver's commit `time`)
===============================================================================================

Status: Proposed.

A design note proposing that each kata event record when the write was sent from
upstream, not only when saver committed it. Nothing here is implemented yet.


- - - -
## Context

Every kata event stores a `time` field. saver sets it itself, at append time,
from its own clock:

    # source/server/model/kata_v2.rb
    new_event = summary.merge!({
      'index' => place_at,
      'time'  => time.now,          # saver's clock, at commit
      'diff_added_count' => added,
      'diff_deleted_count' => deleted
    })

The `merge!` sets `time` unconditionally, so any `time` already present in the
incoming body is overwritten. `time` therefore means "when saver committed the
event", not "when the user's action happened".

Writes reach saver through the spooler, which buffers each write durably and
drains it to saver asynchronously (see the spooler repo's
`adr-async-writes-via-spooler.md`). Today the drain lag is small. The spooler's
second ADR (`docs/async-writes-future-enhancements.md` in that repo) proposes a
persistent retry queue with exponential backoff so a write survives saver being
unavailable. With that in place the gap between when web sent an event and when
saver commits it can grow large (minutes, across a saver outage), and a
commit-time `time` would misrepresent when the user actually did the work.

Ordering does not depend on `time`. The committed position is `index` (head + 1)
and per-writer order is `tab_seq`. `time` is descriptive metadata for display,
not an ordering key.


- - - -
## Decision

Record the send time as a distinct field and keep saver's commit-time `time`
unchanged. Two steps, in two repos:

1. Capture and carry the send time. Stamp it upstream (the browser, or web when
   it receives the request) and include it in the request body as a new field,
   `sent_at`. The spooler forwards the body verbatim, so it needs no change.

2. Stop saver clobbering it. Change the append in `commit_event`
   (`source/server/model/kata_v2.rb`) so it preserves a body-supplied `sent_at`
   rather than dropping or overwriting it. saver's own `time` stays exactly as
   it is: the authoritative commit-time stamp.

We keep `sent_at` as a separate key rather than redefining `time`. `time` stays
saver-authoritative and single-clock; `sent_at` is the (client-trusted) upstream
time. An event then carries both: when the user acted, and when it was committed.


- - - -
## Consequences

- An event gained a new optional field. A pre-change event, or a write whose
  body carries no `sent_at`, simply stores no `sent_at` key, the same way a
  write with no `laptop_id` stores none. Readers must treat it as optional.

- Clock trust changes for the new field only. `sent_at` comes from many web
  instances or browsers, so it carries clock skew and is client-trusted: a
  client could send an arbitrary or backdated value. This is tolerable because
  `sent_at`, like `time`, is descriptive metadata and not the ordering key.
  Keeping it under a distinct name (not `time`) confines the weaker guarantee to
  the new field and leaves `time` fully saver-authoritative.

- No behaviour change until upstream sends `sent_at`. Step 2 is inert on its own
  (no body carries the field yet), so it can land first and independently.
