(uiop/package:define-package :project.package.use/main
                             (:nicknames :project.package.use)
                             (:use :project :cl) (:shadow :use) (:export)
                             (:intern))
(in-package :project.package.use/main)
;;don't edit above

(defun use (r)
  (combine-main r :use))
