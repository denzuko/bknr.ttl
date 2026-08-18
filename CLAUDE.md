# CLAUDE.md

Hand-authored. `.github/workflows/ci.yml` invokes
`denzuko/dps-meta@v1` (`type: lisp-actor`) on GitHub's own runners,
not locally in the environment this repo was scaffolded in, where
neither SBCL nor network access to that runner exists. This file
should be treated as a placeholder until the Action actually runs
against a push to `develop` and regenerates it for real; its output
has not been observed from this environment.

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

This project has no test suite of its own yet. It is a single mixin,
exercised through its consumers' test suites, starting with
`denzuko/bknr.hashkv`.

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
