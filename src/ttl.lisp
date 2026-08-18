;;;; src/ttl.lisp
;;;;
;;;; A plain CLOS mixin over bknr.datastore's persistent-class, giving
;;;; any persisted class CREATED-AT/EXPIRES-AT for the cost of adding
;;;; it to a superclass list. Extends bknr.datastore; not part of the
;;;; bknr project itself — see README for the naming rationale.
;;;;
;;;; This is the verified, load-bearing implementation. A metaclass-
;;;; based alternative that would add these slots without an explicit
;;;; mixin is sketched in src/ttl-metaclass.lisp, but is unverified
;;;; and lives in its own subsystem — see that file's header before
;;;; using it.

(defpackage :bknr.ttl
  (:use :cl)
  (:export #:timestamped-entry
           #:entry-created-at
           #:entry-expires-at
           #:entry-expired-p
           #:register-ttl-class
           #:sweep-expired))

(in-package :bknr.ttl)

(bknr.datastore:defpersistent-class timestamped-entry ()
  ((created-at :initarg :created-at :accessor entry-created-at
               :initform (get-universal-time))
   (expires-at :initarg :expires-at :accessor entry-expires-at
               :initform nil))
  (:documentation "Mixin for any bknr.datastore persistent class that
wants CREATED-AT and EXPIRES-AT for free. Include it in a subclass's
superclass list:

  (bknr.datastore:defpersistent-class my-thing (bknr.ttl:timestamped-entry)
    ((...)))

Then call REGISTER-TTL-CLASS on the concrete class name once, at load
time, so SWEEP-EXPIRED knows to walk it."))

(defun entry-expired-p (entry &optional (now (get-universal-time)))
  "Returns T if ENTRY has an EXPIRES-AT set and it is in the past
relative to NOW. An entry with EXPIRES-AT NIL never expires."
  (let ((expires-at (entry-expires-at entry)))
    (and expires-at (>= now expires-at))))

(defvar *ttl-classes* nil
  "Class names registered via REGISTER-TTL-CLASS. SWEEP-EXPIRED walks
exactly these classes — nothing is registered automatically, each
project opts its own concrete classes in explicitly.")

(defun register-ttl-class (class-name)
  "Registers CLASS-NAME (a symbol naming a TIMESTAMPED-ENTRY subclass)
so SWEEP-EXPIRED will walk its instances. Idempotent."
  (pushnew class-name *ttl-classes*)
  *ttl-classes*)

(defun class-instances-unverified (class-name)
  "Returns every live instance of CLASS-NAME.
UNVERIFIED: bknr.datastore's exact enumeration function/package for
'every instance of this persistent class' was not confirmed against
source in this environment — CLASS-INSTANCES is used here as the
most likely name based on the Allegrocache/Elephant-style API
bknr.datastore is generally modeled after. Confirm against your
installed bknr.datastore before relying on SWEEP-EXPIRED."
  (bknr.datastore:class-instances class-name))

(defun sweep-expired (&optional (now (get-universal-time)))
  "Deletes every expired instance of every class registered via
REGISTER-TTL-CLASS. Returns the count of entries removed."
  (let ((removed 0))
    (dolist (class-name *ttl-classes*)
      (dolist (entry (class-instances-unverified class-name))
        (when (entry-expired-p entry now)
          (bknr.datastore:with-transaction ()
            (bknr.datastore:delete-object entry))
          (incf removed))))
    removed))
