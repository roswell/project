(uiop/package:define-package :project.package.name/main
                             (:nicknames :project.package.name)
                             (:use :project/package :cl) (:shadow) (:export)
                             (:intern))
(in-package :project.package.name/main)
;;don't edit above

(defun name (args)
  (let ((file (first args))
        (from (second args))
        (to (third args)))
    (when (and file
               (probe-file file))
      (let ((package (load-package file)))
        (if (and from to (eql (cadr (assoc :name package)) (safe-read-keyword from)))
            (progn
              (setf (cadr (assoc :name package)) (safe-read-keyword to))
              (save-package package file))
            (when to
              (format *error-output* "~A is not ~A.~%" (cadr (assoc :name package)) from)))))))
