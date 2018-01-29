(uiop/package:define-package :project.project.version/main
                             (:nicknames :project.project.version)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.project.version/main)
;;don't edit above

(defun version (r)
  (let* ((path (find-asd *default-pathname-defaults*))
         (asd (asd path)))
    (cond ((equal (first r) "-d")
           (remf asd :version)
           (setf (asd path) asd))
          ((first r)
           (setf (getf asd :version) (first r))
           (setf (asd path) asd)))))
