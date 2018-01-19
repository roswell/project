(uiop/package:define-package :roswell.package.help/main
                             (:nicknames :roswell.package.help)
                             (:use :roswell.package :cl) (:shadow) (:export)
                             (:intern))
(in-package :roswell.package.help/main)
;;don't edit above

(defun help (&rest r)
  (let ((file (caar r)))
    (if file
        (let ((package (normalize-package (load-package file))))
          (flet ((f (x)
                   (when (cdr (assoc x package))
                     (format t "~(~A~):~%" x)
                     (dolist (i (cdr (assoc x package)))
                       (format t "  ~(~A~)~%" i)))))
            (mapc #'f '(:nicknames :use :shadow))))
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
"))))
