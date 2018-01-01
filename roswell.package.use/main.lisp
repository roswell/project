(uiop/package:define-package :roswell.package.use/main
                             (:nicknames :roswell.package.use)
                             (:use :roswell.package :cl) (:shadow :use)
                             (:export) (:intern))
(in-package :roswell.package.use/main)
;;don't edit above

(defun use (r)
  (combine-main r :use))
