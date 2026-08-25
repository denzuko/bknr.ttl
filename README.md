# bknr.ttl

bknr.ttl is a CLOS mixin that grants any `bknr.datastore` persistent
class `created-at` and `expires-at` slots for the cost of adding it to
a superclass list, together with a registry-driven sweep that deletes
expired entries once they are no longer needed.

## Naming

This library extends `bknr.datastore` rather than belonging to the
bknr project itself. `bknr.indices`, `bknr.impex`, and
`bknr.datastore` are sibling systems shipped from the bknr project's
own repository, maintained under a single upstream authority;
`bknr.ttl` does not join that project. It exists separately, at
`denzuko/bknr.ttl`, as an independently published project that
depends on `bknr.datastore` without shipping from it. Because
Quicklisp's system namespace is flat rather than hierarchical,
nothing technically prevents a dotted system name from outside the
bknr project, which means the repository path, not the system name,
is what discloses who publishes this code.

## Depending on bknr.ttl from your own project

`bknr.ttl` is not yet published to Quicklisp or Ultralisp, so add it
to your own project's `qlfile` as a git source. `bknr.ttl` depends
only on `bknr.datastore`, an ordinary published Quicklisp package, so
this one line is the only entry needed, even for a project that has
nothing to do with `bknr.hashkv`:

```
git bknr.ttl https://github.com/denzuko/bknr.ttl.git :branch develop
```

```sh
qlot install
qlot exec ros -e '(ql:quickload :bknr.ttl)'
```

## Why its own repository

Several kinds of projects want time-to-live behavior without also
wanting a key/value store or a generic queue bundled alongside it:
infosec tooling that expires findings, network tooling that expires
session state, worker-agent code that expires lease records. Keeping
this mixin out of `bknr.hashkv` means any of those projects can
depend on the TTL behavior alone.

## Usage

```lisp
(bknr.datastore:defpersistent-class my-thing (bknr.ttl:timestamped-entry)
  ((...)))

(bknr.ttl:register-ttl-class 'my-thing)
```

Then, on whatever schedule the consuming project chooses:

```lisp
(bknr.ttl:sweep-expired)   ; deletes every expired instance of every
                            ; registered class
```

A caller that only needs to check one entry, rather than sweep the
whole registry, can call `bknr.ttl:entry-expired-p` directly for
lazy expiry on read.

## Two implementations, one of them experimental

- `src/ttl.lisp` implements the mixin described above through plain
  CLOS inheritance, which is well-trodden ground for
  `bknr.datastore`. This is the verified, load-bearing
  implementation.
- `src/ttl-metaclass.lisp` (system `bknr.ttl/metaclass-spike`) sketches
  a `:metaclass`-based alternative that would add TTL without
  requiring an explicit mixin in a class's superclass list. This
  path is unverified: `bknr.datastore`'s own metaclass almost
  certainly hooks its own slot-definition classes to support
  transaction logging, and this spike injects plain
  `closer-mop:standard-direct-slot-definition` instances instead,
  which may mean writes to the injected slots do not persist across
  a restart. Anyone considering this path should check it against
  `bknr.datastore`'s source before relying on it. The main
  `bknr.ttl` system neither depends on nor loads this file.

## Documentation

```sh
ros -e '(asdf:load-system :bknr.ttl/docs)(bknr.ttl/docs:generate)'
```

This renders `@BKNR.TTL-MANUAL`, defined in `src/docs.lisp`, through
`40ants-doc`. The keyword arguments `40ants-doc:document` accepts
have changed across that library's history, so anyone wiring this
into a CI pipeline should confirm the current signature locally
first.

## Testing

```sh
ros -e '(ql:quickload :bknr.ttl/tests)' -e '(bknr.ttl/tests:run-tests)'
```

The suite formalizes the same scenario used to validate the mixin
before this test file existed: a `timestamped-entry` subclass with
one expired instance and one unexpired instance, followed by a call
to `sweep-expired` that should remove only the expired one.

## Consumers

`bknr.hashkv`'s `kv-entry` and `queue-entry` classes are the first
two consumers of this mixin, included here as reference usage rather
than as special cases the mixin was designed around.

## License

BSD 3-Clause. See `LICENSE`.
