(uiop/package:define-package :project/package (:use :cl) (:export :import-main
                              :combine-main :load-package :normalize-package
                              :save-package))
(in-package :project/package)
;;;don't edit above

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
           (intern (combine :intern))
           ;;uiop not implemented.
           ;;recycle
           ;;mix
           ;;reexport
           ;;unintern
           )
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
      (let* ((*package* (find-package :project/main)))
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
              ((equal (second r) "-a")
               (let ((elts (cdr (assoc key package))))
                 (dolist (i (nthcdr 2 r))
                   (pushnew (read-from-string (format nil ":~A" i)) elts))
                 (setf (cdr (assoc key package)) elts)
                 (save-package package (first r))
                 ))
              ((equal (second r) "-d")
               (let ((elts (cdr (assoc key package))))
                 (dolist (i (nthcdr 2 r))
                   (setf elts (remove (read-from-string (format nil ":~A" i)) elts)))
                 (setf (cdr (assoc key package)) elts)
                 (save-package package (first r))))))))

(defun import-main (r key)
  (if (and (first r)
           (probe-file (first r)))
      (let* ((package (normalize-package (load-package (first r))))
             (imports (remove key package
                              :test (complement #'eql)
                              :key #'first))
             (imports- (remove key package
                               :test #'eql
                               :key #'first)))
        (cond ((null (rest r))
               (loop for i in imports
                  do (format t "~(~A~%~{  ~A~%~}~)" (second i) (cddr i))))
              ((equal (second r) "-a")
               (dolist (i (nthcdr 2 r))
                 (pushnew (list key (read-from-string (format nil ":~A" i)))
                          imports :key #'second))
               (save-package (normalize-package (append imports- imports)) (first r)))
              ((equal (second r) "-d")
               (dolist (i (nthcdr 2 r))
                 (setf imports (remove (read-from-string (format nil ":~A" i))
                                       imports :key #'second)))
               
               (save-package (normalize-package (append imports- imports)) (first r)))
              ((equal (third r) "-a")
               (loop with found = (find (read-from-string (format nil ":~A" (second r)))
                                        imports :key #'second)
                  with result = (cddr found)
                  for i in (nthcdr 3 r)
                  do (pushnew (read-from-string (format nil ":~A" i)) result)
                  finally
                    (setf (cddr found) result)
                    (save-package (normalize-package (append imports- imports)) (first r))))
              ((equal (third r) "-d")
               (loop with found = (find (read-from-string (format nil ":~A" (second r)))
                                        imports :key #'second)
                  with result = (cddr found)
                  for i in (nthcdr 3 r)
                  do (setf result (remove (read-from-string (format nil ":~A" i)) result))
                  finally
                    (setf (cddr found) result)
                    (save-package (normalize-package (append imports- imports)) (first r))))
              ((second r)
               (let ((i (find (read-from-string (format nil ":~A" (second r)))
                                  imports :key #'second)))
                 (format t "~(~A~%~{  ~A~%~}~)" (second i) (cddr i))))))))

