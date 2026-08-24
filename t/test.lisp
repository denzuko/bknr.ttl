;;;; t/test.lisp
;;;;
;;;; Formalizes the same logic verified interactively via Swank
;;;; earlier: define a TIMESTAMPED-ENTRY subclass, register it,
;;;; create one expired and one unexpired instance, confirm
;;;; SWEEP-EXPIRED removes exactly the expired one.

(defpackage :bknr.ttl/tests
  (:use :cl :fiveam)
  (:export #:run-tests))

(in-package :bknr.ttl/tests)

(def-suite bknr.ttl-suite :description "bknr.ttl mixin tests")
(in-suite bknr.ttl-suite)

(defvar *test-directory* #P"/tmp/bknr.ttl-test-store/")

(bknr.datastore:defpersistent-class test-entry (bknr.ttl:timestamped-entry) ())

(bknr.ttl:register-ttl-class 'test-entry)

(defun fresh-store ()
  "Deletes and reopens a scratch datastore, so each test starts isolated."
  (when (and (boundp 'bknr.datastore:*store*) bknr.datastore:*store*)
    (bknr.datastore:close-store))
  (when (probe-file *test-directory*)
    (uiop:delete-directory-tree *test-directory* :validate t))
  (make-instance 'bknr.datastore:mp-store
                  :directory *test-directory*
                  :subsystems (list (make-instance 'bknr.datastore:store-object-subsystem))))

(test entry-expired-p-reflects-expires-at
  (fresh-store)
  (is (bknr.ttl:entry-expired-p
       (bknr.datastore:with-transaction ()
         (make-instance 'test-entry :expires-at (- (get-universal-time) 10)))))
  (is (not (bknr.ttl:entry-expired-p
            (bknr.datastore:with-transaction ()
              (make-instance 'test-entry :expires-at (+ (get-universal-time) 10000))))))
  (is (not (bknr.ttl:entry-expired-p
            (bknr.datastore:with-transaction ()
              (make-instance 'test-entry :expires-at nil)))))
  (bknr.datastore:close-store))

(test sweep-expired-removes-only-expired-entries
  (fresh-store)
  (bknr.datastore:with-transaction ()
    (make-instance 'test-entry :expires-at (- (get-universal-time) 10)))
  (bknr.datastore:with-transaction ()
    (make-instance 'test-entry :expires-at (+ (get-universal-time) 10000)))
  (is (= 2 (length (bknr.datastore:class-instances 'test-entry))))
  (is (= 1 (bknr.ttl:sweep-expired)))
  (is (= 1 (length (bknr.datastore:class-instances 'test-entry))))
  (bknr.datastore:close-store))

(defun run-tests ()
  "Runs the bknr.ttl test suite and returns T if every test passed."
  (fiveam:run! 'bknr.ttl-suite))
