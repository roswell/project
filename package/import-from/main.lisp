(uiop/package:define-package :project.package.import-from/main
                             (:nicknames :project.package.import-from)
                             (:use :project/package :cl) (:shadow) (:export) (:intern))
(in-package :project.package.import-from/main)
;;don't edit above

(defun import-from (r)
  (import-main r :import-from))
