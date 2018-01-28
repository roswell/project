(uiop/package:define-package :roswell.package.shadow/main
                             (:nicknames :roswell.package.shadow)
                             (:use :project :cl) (:shadow :shadow) (:export)
                             (:intern))
(in-package :roswell.package.shadow/main)
;;don't edit above

(defun shadow (r)
  (combine-main r :shadow))
