(uiop/package:define-package :project.project.add/main
                             (:nicknames :project.project.add)
                             (:use :project/system :project.project.touch/main :cl) (:shadow)
                             (:export :add) (:intern))
(in-package :project.project.add/main)
;;don't edit above
(defun components-insert (components path name system &optional processed)
  (setf components (copy-list components))
  (setf name (format nil "~A/~{~A/~}~A" system path name))
  (if (find-if (lambda (x)
                 (equal x name))
               components)
      (error  "already exist ~A" name)
      (cons name components)))

(defun add-file (file &optional asd asd-path)
  (unless (setq file (probe-file file))
    (error "file not found ~A~%" file))
  (let* ((asd-path (or asd-path (find-asd file)))
         (asd (or asd (asd asd-path)))
         dir)
    (unless asd-path
      (error "can't find asd~%"))
    (setf dir (make-pathname :defaults asd-path :type nil :name nil))
    (setf (getf asd :depends-on)
          (components-insert
           (getf asd :depends-on)
           (subseq (pathname-directory file) (length (pathname-directory dir)))
           (pathname-name file)
           (getf asd :name)))
    (touch-file file asd asd-path)))

(defun add (r)
  (if r
      (let (asd asd-path)
        (dolist (file r)
          (when (and asd-path
                     (not (equal asd-path (find-asd file))))
            (error "~A is not insert in same project." file))
          (multiple-value-setq (asd asd-path)
            (add-file file asd asd-path)))
        (setf (getf asd :class) :package-inferred-system)
        (setf (asd asd-path) asd))))
