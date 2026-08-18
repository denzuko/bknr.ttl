# CLAUDE.md

Hand-authored — the `dps-meta` generator was not available in the
environment this repo was scaffolded in. Regenerate via `dps-meta`
when convenient; this file should be treated as a placeholder for
that, not a permanent hand-maintained document.

## Project Identity

| Field        | Value |
|--------------|-------|
| Application  | bknr.ttl |
| Description  | CLOS mixin adding CREATED-AT/EXPIRES-AT and a sweep registry to any bknr.datastore persistent class |
| Type         | Common Lisp library |
| Version      | 1.0.0 |
| Branch       | develop |
| Licence      | BSD-3-Clause |
| Organisation | denzuko |

## Standards Stack

- BSD-3-Clause license
- git-flow branching, `develop` as the integration branch
- Semver: MAJOR = public API/interface break only; MINOR = new non-breaking capability; PATCH = everything else

## BDD Workflow

xUnit-style (this project has no test suite of its own yet — it is a
single mixin, exercised through its consumers' test suites, starting
with `denzuko/bknr.hashkv`).

## Subcommands

None — this is a library with no `.ros` entry point.

## Do Not

- Do not use `bknr.ttl/metaclass-spike` (`src/ttl-metaclass.lisp`)
  without first verifying it against `bknr.datastore`'s
  transaction-logging internals — see that file's header and the
  README for the specific unresolved risk.
- Do not assume `bknr.ttl` is part of the upstream bknr project — it
  extends `bknr.datastore` from a separate repo; see README for the
  naming rationale.
