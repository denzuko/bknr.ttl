# bknr.ttl

A CLOS mixin that gives any `bknr.datastore` persistent class
`created-at`/`expires-at` for the cost of adding it to a superclass
list, plus a registry-driven sweep to delete expired entries.

## Naming

This extends `bknr.datastore`; it is not part of the bknr project
itself. `bknr.indices`, `bknr.impex`, and `bknr.datastore` are sibling
systems shipped from the bknr project's own repository. This one
isn't — it's `denzuko/bknr.ttl`, a separate, independently published
project that depends on `bknr.datastore` rather than shipping from it.
Quicklisp's system namespace is flat, not hierarchical, so nothing
prevents the dotted name; the repo path (`denzuko/bknr.ttl`) is what
actually discloses provenance.

## Why its own repo

Several projects want TTL without wanting a key/value store or a job
queue along with it — infosec tooling, network tooling, worker-agent
state. Keeping this out of `bknr.hashkv` means any of them can depend
on just this.

## Usage

```lisp
(bknr.datastore:defpersistent-class my-thing (bknr.ttl:timestamped-entry)
  ((...)))

(bknr.ttl:register-ttl-class 'my-thing)
```

Then, periodically:

```lisp
(bknr.ttl:sweep-expired)   ; deletes every expired instance of every
                            ; registered class
```

Individual callers can also check `bknr.ttl:entry-expired-p` directly
for lazy expiry on read, rather than waiting for a sweep.

## Two implementations, one of them experimental

- `src/ttl.lisp` — the mixin above. Plain CLOS inheritance, which is
  well-trodden ground for `bknr.datastore`. This is what's verified
  and load-bearing.
- `src/ttl-metaclass.lisp` (system `bknr.ttl/metaclass-spike`) — a
  `:metaclass`-based alternative that would add TTL without an
  explicit mixin. **Unverified**: `bknr.datastore`'s own metaclass
  almost certainly hooks its own slot-definition classes for
  transaction logging, and this spike injects plain
  `closer-mop:standard-direct-slot-definition` instances instead —
  which may mean writes to the injected slots silently don't persist
  across a restart. Check this against `bknr.datastore`'s source
  before using it for anything real. The main `bknr.ttl` system does
  not depend on or load this file.

## Consumers

`bknr.hashkv`'s `kv-entry` and `queue-entry` are the first two
consumers of the mixin — reference usage, not special cases.

## License

BSD 3-Clause. See `LICENSE`.
