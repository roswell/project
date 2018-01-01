(uiop/package:define-package :roswell.package.nicknames/main (:use :roswell.package :cl) (:nicknames :roswell.package.nicknames))
(in-package :roswell.package.nicknames/main)
;;;don't edit above

(defun nicknames (r)
  (combine-main r :nicknames))
