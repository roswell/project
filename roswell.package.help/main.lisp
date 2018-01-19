(uiop/package:define-package :roswell.package.help/main
                             (:nicknames :roswell.package.help) (:use :cl)
                             (:shadow) (:export) (:intern))
(in-package :roswell.package.help/main)
;;don't edit above

(defun help (&rest r)
  (format t "Usage:

ros package file export -a/-d symbol*
ros package file nicknames -a/-d package*
ros package file shadow -a/-d symbol*
ros package file use -a/-d package*
ros package file import-from -a/-d package*
ros package file import-from package -a/-d symbol*
ros package file shadowing-import-from -a/-d package*
ros package file shadowing-import-from package -a/-d symbol*

See also:
`ros project`
"))
