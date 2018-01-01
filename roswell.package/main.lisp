(uiop/package:define-package :roswell.package/main
                             (:nicknames :roswell.package) (:use :cl) (:shadow)
                             (:export :combine-main :load-package
                              :normalize-package :save-package)
                             (:intern))
(in-package :roswell.package/main)
;;don't edit above
(defun load-package (file)
  (let ((exp (with-open-file (in file)
               (read in))))
    (assert (eql 'uiop/package:define-package (first exp)))
    (setf exp (cdr exp)
          exp (cons (list :name (first exp)) (rest exp)))
    exp))

(defun normalize-package (package)
  (flet ((single (x)
           (assoc x package))
         (combine (x)
           (cons x (apply #'append
                          (mapcar #'rest
                                  (remove x package
                                          :key 'first
                                          :test (complement #'equal))))))
         (collect (x)
           (remove x package
                   :key 'first
                   :test (complement #'equal))))
    (let* ((name (single :name))
           (nicknames (combine :nicknames))
           (documentation (single :documentation))
           (use (combine :use))
           (shadow (combine :shadow))
           (shadow-import (collect :shadowing-import-from))
           (import (collect :import-from))
           (export (combine :export))
           (intern (combine :intern)))
      (dolist (i '(:name :nicknames :documentation :use :shadow
                   :shadowing-import-from :import-from :export :intern))
        (setf package (remove i package :test 'equal :key #'first)))
      `(,name ,nicknames
              ,@(when documentation (list documentation)) ,use ,shadow 
              ,@shadow-import
              ,@import
              ,export ,intern
              ,@package))))

(defun save-package (package path)
  (let (seq)
    (with-open-file (in path)
      (assert (eql 'uiop/package:define-package (first (read in)))) ;;defpackage
      (assert (eql 'in-package (first (read in)))) ;; in-package
      (assert (eql #\; (aref (read-line in) 0)))   ;; comment
      (setf seq (make-array (file-length in)
                            :element-type 'character
                            :fill-pointer t)
            (fill-pointer seq) (read-sequence seq in)))
    (with-open-file (out path
                         :direction :output
                         :if-exists :supersede)
      (let* ((*package* (find-package :roswell.package/main)))
        (format out "~(~S~%~S~%~);;don't edit above~%~A"
                `(uiop/package:define-package ,(second (first package)) ,@(cdr package))
                `(in-package ,(second (first package)))
                seq)))))

(defun combine-main (r key)
  (if (and (first r)
           (probe-file (first r)))
      (let ((package (normalize-package (load-package (first r)))))
        (cond ((null (rest r))
               (format t "~{~(~A~%~)~}" (cdr (assoc key package))))
              ((find (second r) '("-a" "add") :test 'equal)
               (let ((elts (cdr (assoc key package))))
                 (dolist (i (nthcdr 2 r))
                   (pushnew (read-from-string (format nil ":~A" i)) elts))
                 (setf (cdr (assoc key package)) elts)
                 (save-package package (first r))
                 ))
              ((find (second r) '("-d" "rm") :test 'equal)
               (let ((elts (cdr (assoc key package))))
                 (dolist (i (nthcdr 2 r))
                   (setf elts (remove (read-from-string (format nil ":~A" i)) elts)))
                 (setf (cdr (assoc key package)) elts)
                 (save-package package (first r))))))))
