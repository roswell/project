(uiop/package:define-package :project.project.depends-on/main
                             (:nicknames :project.project.depends-on)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.project.depends-on/main)
;;don't edit above

(defun depends-on (r)
  (let ((key :depends-on)
        (path (find-asd "./")))
    (if r
        (when path
          (cond
            ((find (first r) '("-a" "add") :test 'equal)
             (let* ((asd (asd path))
                    (elts (getf asd key))
                    (origlen (length elts)))
               (dolist (i (nthcdr 1 r))
                 (pushnew (read-from-string (format nil ":~A" i)) elts))
               (unless (eql (length elts) origlen)
                 (setf (getf asd key) elts)
                 (setf (asd path) asd))))
            ((find (first r) '("-d" "rm") :test 'equal)
             (let* ((asd (asd path))
                    (elts (getf asd key))
                    (origlen (length elts)))
               (dolist (i (nthcdr 1 r))
                 (setf elts (remove (read-from-string (format nil ":~A" i)) elts)))
               (unless (eql (length elts) origlen)
                 (setf (getf asd key) elts)
                 (setf (asd path) asd))))))
        (when path
          (format t "~(~{~A~%~}~)" (getf (asd path) key))))))
