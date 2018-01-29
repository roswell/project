(uiop/package:define-package :project.package.shadowing-import-from/main
                             (:nicknames
                              :project.package.shadowing-import-from)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.package.shadowing-import-from/main)
;;don't edit above

(defun shadowing-import-from(r)
  (import-main r :shadowing-import-from))
