(uiop/package:define-package :project.project.author/main
                             (:nicknames :project.project.author)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.project.author/main)
;;don't edit above

(defun author (r)
  (let* ((path (find-asd *default-pathname-defaults*))
         (asd (asd path)))
    (cond ((equal (first r) "-d")
           (remf asd :author)
           (setf (asd path) asd))
          ((first r)
           (setf (getf asd :author) (first r))
           (setf (asd path) asd)))))
