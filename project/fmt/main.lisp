(uiop/package:define-package :project.project.fmt/main (:use :project/system :cl)
  (:nicknames :project.project.fmt))
(in-package :project.project.fmt/main)
;;;don't edit above
(defun fmt (r)
  (declare (ignore r))
  (let ((path (find-asd *default-pathname-defaults*)))
    (setf (asd path) (asd path))))
