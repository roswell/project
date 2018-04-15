(uiop/package:define-package :project.project.rm/src/main
                             (:nicknames :project.project.rm) (:use :project/system :cl)
                             (:shadow) (:export) (:intern))
(in-package :project.project.rm/src/main)
;;don't edit above
(defun components-rm (components path name type &optional processed)
  (when path
    (setf name (format nil "~{~A/~}~A" path name)))
  (remove (list type
                name)
          components
          :test (lambda (x y)
                  (and (equal (first x) (first y))
                       (equal (second x) (second y))))))
(defun rm-file (file &optional asd asd-path)
  (unless (setq file (probe-file file))
    (error "file not found ~A~%" file1))
  (let* ((asd-path (or asd-path (find-asd file)))
         (asd (or asd (asd asd-path)))
         dir)
    (unless asd-path
      (error "can't find asd~%"))
    (setf dir (make-pathname :defaults asd-path :type nil :name nil))
    (setf (getf asd :components)
          (components-rm
           (getf asd :components)
           (subseq (pathname-directory file) (length (pathname-directory dir)))
           (pathname-name file)
           (second (assoc (pathname-type file) *type-keyword-assoc* :test 'equal))))
    (setf (asd asd-path) asd))
  (values asd asd-path))

(defun rm (r &rest other)
  (declare (ignorable other))
  (let (asd asd-path)
    (dolist (file r)
      do (multiple-value-setq (asd asd-path)
           (rm-file file)))))
