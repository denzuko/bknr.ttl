;;;; src/docs.lisp
;;;;
;;;; bknr.ttl's manual, defined with 40ants-doc, rendered with
;;;; 40ants-doc-full/builder:render-to-string (verified against an
;;;; actual installed copy; the system that has DOCUMENT does not
;;;; exist under that name).

(defpackage :bknr.ttl/docs
  (:use :cl)
  (:import-from #:40ants-doc #:defsection)
  (:import-from #:40ants-doc-full/builder #:render-to-string)
  (:export #:@bknr.ttl-manual
           #:generate))

(in-package :bknr.ttl/docs)

(defsection @bknr.ttl-manual (:title "bknr.ttl")
  "A CLOS mixin adding CREATED-AT/EXPIRES-AT to any bknr.datastore
persistent class, plus a registry-driven sweep for expired entries."
  (bknr.ttl:timestamped-entry class)
  (bknr.ttl:entry-created-at generic-function)
  (bknr.ttl:entry-expires-at generic-function)
  (bknr.ttl:entry-expired-p function)
  (bknr.ttl:register-ttl-class function)
  (bknr.ttl:sweep-expired function))

(defun generate (&optional (stream *standard-output*) (format :markdown))
  "Renders @BKNR.TTL-MANUAL to STREAM in FORMAT (:markdown or :html)."
  (write-string (render-to-string @bknr.ttl-manual :format format) stream))
