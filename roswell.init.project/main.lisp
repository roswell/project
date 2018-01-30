(uiop/package:define-package :roswell.init.project/main (:use :cl :project.project.init) (:nicknames :roswell.init.project))
(in-package :roswell.init.project/main)
;;;don't edit above

(defun project (project &rest params)
  (init params))
