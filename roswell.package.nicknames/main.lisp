(uiop/package:define-package :roswell.package.nicknames/main
                             (:nicknames :roswell.package.nicknames)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :roswell.package.nicknames/main)
;;don't edit above

(defun nicknames (r)
  (combine-main r :nicknames))
