(uiop/package:define-package :roswell.package.shadowing-import-from/main
                             (:nicknames
                              :roswell.package.shadowing-import-from)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :roswell.package.shadowing-import-from/main)
;;don't edit above

(defun shadowing-import-from(r)
  (import-main r :shadowing-import-from))
