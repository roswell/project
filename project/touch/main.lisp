(uiop/package:define-package :project.project.touch/main
                             (:nicknames :project.project.touch)
                             (:use :project/system :cl) (:shadow)
                             (:export :touch-file) (:intern))
(in-package :project.project.touch/main)
;;don't edit above

(defun touch-file (file &optional asd asd-path)
  (unless (setq file (probe-file file))
    (error "file not found ~A~%" file))
  (let* ((asd-path (or asd-path (find-asd file)))
         (asd (or asd (asd asd-path)))
         dir)
    (unless asd-path
      (error "can't find asd~%"))
    (unless (eql (getf asd :class)
                 :package-inferred-system)
      (setf (getf asd :class) :package-inferred-system
            (asd asd-path) asd))
    (setf dir (make-pathname :defaults asd-path :type nil :name nil))
    (let ((relative (subseq (pathname-directory file) (length (pathname-directory dir)))))
      (when (equal (pathname-type file) "lisp")
        (ensure-defpackage (format nil "~A/~{~A/~}~A"
                                   (getf asd :name)
                                   relative
                                   (pathname-name file))
                           file)))
    (values asd asd-path)))

(defun touch (r)
  (if r
      (dolist (e r)
        (unless (pathname-type e)
          (setf e (make-pathname :defaults e :type "lisp")))
        (cond ((equal (pathname-type e) "lisp")
               (open e :direction :probe :if-does-not-exist :create)
               (touch-file e))
              ((equal (pathname-type e) "ros")
               (let* ((path (find-asd *default-pathname-defaults*))
                      (asd (asd path)))
                 (format t "name:~A~%" (getf asd :name))))))))
