# CLAUDE.md

Hand-authored. `denzuko/dps-meta@v1` was tried as the CI-driven
generator for this file but has a confirmed upstream bug. Its
"Checkout dps-meta source" step fetches a `v4` ref that doesn't exist
in that repo, failing unconditionally for every consumer regardless
of configuration. `.github/workflows/ci.yml` runs real, working CI
instead (unit tests, docs build) via a plain Roswell/qlot install,
matching `denzuko/edm-engine`'s proven pattern. This file remains a
hand-authored placeholder; regenerate via `dps-meta` once its
upstream bug is fixed, or hand-maintain it going forward.

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
- 40ants-doc for documentation (`bknr.ttl/docs`)

## BDD Workflow

`t/test.lisp` (system `bknr.ttl/tests`) formalizes what was verified
interactively before this file was written: a `timestamped-entry`
subclass, one expired and one unexpired instance, `sweep-expired`
removing exactly the expired one. Also exercised through consumers'
own test suites, starting with `denzuko/bknr.hashkv`.

## Subcommands

None. This is a library with no `.ros` entry point.

## Do Not

- Do not use `bknr.ttl/metaclass-spike` (`src/ttl-metaclass.lisp`)
  without first verifying it against `bknr.datastore`'s
  transaction-logging internals. See that file's header and the
  README for the specific unresolved risk.
- Do not assume `bknr.ttl` is part of the upstream bknr project. It
  extends `bknr.datastore` from a separate repo; see README for the
  naming rationale.
