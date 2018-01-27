(uiop/package:define-package :roswell.project.help/main
                             (:nicknames :roswell.project.help) (:use :cl)
                             (:shadow) (:export) (:intern))
(in-package :roswell.project.help/main)
;;don't edit above

(defun help (&rest r)
  (format t "Usage:

ros init project new-project
ros project add file*
ros project depends-on -a/-d symbol*
ros project author -d/name
ros project mailto -d/email
ros project license -d/license
ros project version -d/version

See also:
`ros package`
"))
