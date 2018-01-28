(uiop/package:define-package :roswell.package.import-from/main
                             (:nicknames :roswell.package.import-from)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :roswell.package.import-from/main)
;;don't edit above

(defun import-from (r)
  (import-main r :import-from))
