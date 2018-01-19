(uiop/package:define-package :roswell.project.help/main
                             (:nicknames :roswell.project.help) (:use :cl)
                             (:shadow) (:export) (:intern))
(in-package :roswell.project.help/main)
;;don't edit above

(defun help (&rest r)
  (format t "Usage:

ros project add file*
ros project depends-on -a/-d symbol*

See also:
`ros package`
"))
