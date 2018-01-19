(uiop/package:define-package :roswell.project/main
                             (:nicknames :roswell.project) (:use :cl)
                             (:shadow) (:export :find-asd :asd :ensure-defpackage) (:intern))
(in-package :roswell.project/main)
;;don't edit above
(defun find-asd (dir)
  (let* ((prj (loop
                 :for path := (make-pathname
                               :defaults dir
                               :name "project"
                               :type "lisp")
                 :when (probe-file path)
                 :do (return path)
                 :when (equal (ignore-errors (pathname-directory (truename dir))) '(:absolute))
                 :do (return nil)
                 :do (setf dir (uiop:pathname-parent-directory-pathname dir))))
         (*read-eval*)
         (name (with-open-file (in prj)
                 (second (assoc "asd" (second (second (first (second (read in)))))
                              :test 'equal)))))
    (probe-file (make-pathname :defaults prj :name name :type "asd"))))

(defun asd (path)
  (when path
    (with-open-file (in path)
      (with-standard-io-syntax
        (in-package :roswell.project/main)
        (let* ((*read-eval*)
               (asd (read in)))
          (assert (eql (first asd) 'defsystem))
          (cons :name (cdr asd)))))))

(defun (setf asd) (asd path)
  (when path
    (let* ((asd (copy-list asd))
           (name (getf asd :name)))
      (assert name)
      (remf asd :name)
      (with-open-file (out path
                           :direction :output
                           :if-exists :supersede)
        (let* ((*package* (find-package :roswell.project/main)))
          (format out ";;don't edit~%~S"
                  `(defsystem ,name
                     ,@asd))))))
  asd)

(defun ensure-defpackage (name file)
  (let ((1stexp (with-open-file (in file)
                  (let (*read-eval*)
                    (ignore-errors (read in))))))
    (unless (eql (first 1stexp) 'uiop:define-package)
      (let* ((content (with-open-file (stream file)
                        (let ((seq (make-array (file-length stream)
                                               :element-type 'character
                                               :fill-pointer t)))
                          (setf (fill-pointer seq) (read-sequence seq stream))
                          seq)))
             (package (read-from-string (format nil ":~A" name))))
        (with-open-file (out file
                             :direction :output
                             :if-exists :supersede)
          (format out "~(~S~%~S~%~);;;don't edit above~%~A"
                  `(uiop:define-package ,package
                       (:use :cl))
                  `(in-package ,package)
                  content))))))
