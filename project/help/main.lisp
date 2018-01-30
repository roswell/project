(uiop/package:define-package :project.project.help/main
                             (:nicknames :project.project.help)
                             (:use :project/system :cl) (:shadow) (:export) (:intern))
(in-package :project.project.help/main)
;;don't edit above

(defun help (&rest r)
  (format t "Usage:

ros project init new-project
ros project add file*
ros project depends-on -a/-d symbol*
ros project author -d/name
ros project mailto -d/email
ros project license -d/license
ros project version -d/version

See also:
`ros package`
"))
