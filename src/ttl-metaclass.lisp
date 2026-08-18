;;;; src/ttl-metaclass.lisp
;;;;
;;;; EXPERIMENTAL / UNVERIFIED. This file IS the spike, not a
;;;; validated implementation. Nothing in bknr.ttl's main system loads
;;;; or depends on it; timestamped-entry (src/ttl.lisp) is the
;;;; verified, load-bearing path.
;;;;
;;;; The idea, once worth doing: a metaclass that injects CREATED-AT
;;;; and EXPIRES-AT onto any class declaring :metaclass
;;;; ttl-persistent-class, so a class gets TTL without writing the
;;;; mixin into its superclass list. Worth the complexity once several
;;;; unrelated projects (infosec tooling, network tooling, worker-agent
;;;; state) want the same behavior "for free."
;;;;
;;;; UNRESOLVED RISK. Check this before using this file for anything
;;;; real: bknr.datastore's own PERSISTENT-CLASS metaclass almost
;;;; certainly defines its own effective/direct-slot-definition
;;;; classes to hook (setf slot-value-using-class) for transaction
;;;; logging. The slot-injection below builds plain
;;;; CLOSER-MOP:STANDARD-DIRECT-SLOT-DEFINITION instances rather than
;;;; bknr.datastore's own slot-definition class, which means writes to
;;;; CREATED-AT/EXPIRES-AT on an instance of a class using this
;;;; metaclass may not be captured by bknr's transaction log at all,
;;;; i.e. may silently fail to persist across a restart. This has to
;;;; be checked against bknr.datastore's actual source before this
;;;; file is used for anything, and the exact CLOSER-MOP function
;;;; signatures below (MAKE-DIRECT-SLOT-DEFINITION's keyword
;;;; arguments in particular) are written from general MOP knowledge,
;;;; not confirmed against an installed closer-mop in this
;;;; environment. Treat this file as a starting point for the spike,
;;;; not as tested code.

(defpackage :bknr.ttl/metaclass-spike
  (:use :cl)
  (:export #:ttl-persistent-class))

(in-package :bknr.ttl/metaclass-spike)

(defclass ttl-persistent-class (bknr.datastore:persistent-class)
  ()
  (:documentation "See file header: experimental, unverified against
bknr.datastore's transaction-logging mechanism. Not used by bknr.ttl
or bknr.hashkv."))

(defmethod closer-mop:validate-superclass
    ((class ttl-persistent-class) (superclass bknr.datastore:persistent-class))
  t)

(defun ttl-direct-slots (class)
  "Builds the CREATED-AT/EXPIRES-AT direct-slot-definitions to inject
into CLASS. See file header re: the transaction-logging risk this
does not resolve."
  (list (closer-mop:make-direct-slot-definition
         class
         :name 'created-at
         :initargs '(:created-at)
         :readers '(entry-created-at)
         :writers '((setf entry-created-at))
         :initform '(get-universal-time)
         :initfunction (lambda () (get-universal-time)))
        (closer-mop:make-direct-slot-definition
         class
         :name 'expires-at
         :initargs '(:expires-at)
         :readers '(entry-expires-at)
         :writers '((setf entry-expires-at))
         :initform nil
         :initfunction (constantly nil))))

(defmethod closer-mop:initialize-instance-using-class :around
    ((class ttl-persistent-class) &rest initargs &key direct-slots &allow-other-keys)
  (let ((cleaned (copy-list initargs)))
    (remf cleaned :direct-slots)
    (apply #'call-next-method class
           :direct-slots (append direct-slots (ttl-direct-slots class))
           cleaned)))

(defmethod closer-mop:reinitialize-instance-using-class :around
    ((class ttl-persistent-class) &rest initargs &key direct-slots &allow-other-keys)
  (let ((cleaned (copy-list initargs)))
    (remf cleaned :direct-slots)
    (apply #'call-next-method class
           :direct-slots (append direct-slots (ttl-direct-slots class))
           cleaned)))
