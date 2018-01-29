(uiop/package:define-package :project.package.nicknames/main
                             (:nicknames :project.package.nicknames)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.package.nicknames/main)
;;don't edit above

(defun nicknames (r)
  (combine-main r :nicknames))
