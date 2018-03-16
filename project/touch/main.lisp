(uiop/package:define-package :project.project.touch/main
                             (:nicknames :project.project.touch)
                             (:use :project.project.add/main :cl) (:shadow)
                             (:export) (:intern))
(in-package :project.project.touch/main)
;;don't edit above

(defun touch (r)
  (if r
      (dolist (e r)
        (open e :direction :probe :if-does-not-exist :create)
        (add (list e)))))
