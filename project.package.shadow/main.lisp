(uiop/package:define-package :project.package.shadow/main
                             (:nicknames :project.package.shadow)
                             (:use :project :cl) (:shadow :shadow) (:export)
                             (:intern))
(in-package :project.package.shadow/main)
;;don't edit above

(defun shadow (r)
  (combine-main r :shadow))
