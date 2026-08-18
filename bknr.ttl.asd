;;;; bknr.ttl.asd
;;;;
;;;; Extends bknr.datastore. Not part of the bknr project itself.
;;;; The dotted name matches convention (bknr.indices, bknr.impex are
;;;; siblings in that suite) but this repo, and the system it
;;;; publishes, is denzuko/bknr.ttl, a separate project that depends
;;;; on bknr.datastore rather than shipping from it.

(asdf:defsystem "bknr.ttl"
  :description "CLOS mixin adding CREATED-AT/EXPIRES-AT and a sweep registry to any bknr.datastore persistent class."
  :author "Dwight Spencer"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :depends-on ("bknr.datastore")
  :pathname "src/"
  :components ((:file "ttl")))

(asdf:defsystem "bknr.ttl/docs"
  :description "40ants-doc manual definition for bknr.ttl."
  :license "BSD-3-Clause"
  :depends-on ("bknr.ttl" "40ants-doc")
  :pathname "src/"
  :components ((:file "docs")))

(asdf:defsystem "bknr.ttl/metaclass-spike"
  :description "EXPERIMENTAL metaclass alternative to the timestamped-entry mixin, unverified against bknr.datastore's transaction-logging internals. Not depended on by the main bknr.ttl system. See src/ttl-metaclass.lisp header before using."
  :license "BSD-3-Clause"
  :depends-on ("bknr.datastore" "closer-mop")
  :pathname "src/"
  :components ((:file "ttl-metaclass")))
