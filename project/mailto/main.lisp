(uiop/package:define-package :project.project.mailto/main
                             (:nicknames :project.project.mailto)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.project.mailto/main)
;;don't edit above

(defun mailto (r)
  (let* ((path (find-asd *default-pathname-defaults*))
         (asd (asd path)))
    (cond ((equal (first r) "-d")
           (remf asd :mailto)
           (setf (asd path) asd))
          ((first r)
           (setf (getf asd :mailto) (first r))
           (setf (asd path) asd)))))
