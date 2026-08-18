;;;; src/docs.lisp
;;;;
;;;; bknr.ttl's manual, defined with 40ants-doc.
;;;;
;;;; NOTE: 40ants-doc:document's exact keyword arguments have changed
;;;; across that library's history. Confirm the current signature
;;;; locally before relying on this in CI.

(defpackage :bknr.ttl/docs
  (:use :cl)
  (:import-from #:40ants-doc #:defsection #:document)
  (:export #:@bknr.ttl-manual
           #:generate))

(in-package :bknr.ttl/docs)

(defsection @bknr.ttl-manual (:title "bknr.ttl")
  "A CLOS mixin adding CREATED-AT/EXPIRES-AT to any bknr.datastore
persistent class, plus a registry-driven sweep for expired entries."
  (bknr.ttl:timestamped-entry class)
  (bknr.ttl:entry-created-at function)
  (bknr.ttl:entry-expires-at function)
  (bknr.ttl:entry-expired-p function)
  (bknr.ttl:register-ttl-class function)
  (bknr.ttl:sweep-expired function))

(defun generate (&optional (stream *standard-output*) (format :markdown))
  "Renders @BKNR.TTL-MANUAL to STREAM in FORMAT (:markdown or :html)."
  (document @bknr.ttl-manual :stream stream :format format))
