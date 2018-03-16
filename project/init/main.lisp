(uiop/package:define-package :project.project.init/main
                             (:nicknames :project.project.init) (:use :cl)
                             (:shadow) (:export :init) (:intern))
(in-package :project.project.init/main)
;;don't edit above
(defvar *loader* '(dolist (n (assoc "asd" data :test 'equal))
                   (funcall (read-from-string "asdf:load-asd")
                    (make-pathname
                     :defaults *load-pathname*
                     :name n
                     :type "asd"))))

(defun prepare-project (name dir)
  (let ((path (merge-pathnames (make-pathname :name "project" :type "lisp") dir)))
    (unless (with-open-file (out path
                                 :direction :output
                                 :if-exists nil
                                 :if-does-not-exist :create)
              (when out
                (let ((*package* (find-package :project.project.init/main)))
                  (format out ";;don't edit~%~(~S~)~%"
                          `(let ((data '(("asd" . ,(list name)))))
                             ,*loader*)))
                (format t "~&Successfully generated: ~A~%" path)
                t))
      (format *error-output* "~&File already exists: ~A~%" path)
      (return-from prepare-project nil))
    t))

(defun prepare-asd (name dir)
  (let ((path (merge-pathnames (make-pathname :name name :type "asd") dir)))
    (or (with-open-file (out path
                             :direction :output
                             :if-exists nil
                             :if-does-not-exist :create)
          (let ((*package* (find-package :project.project.init/main)))
            (when out
              (format out ";;don't edit~%~S"
                      `(defsystem ,name
                         :author ,(project/main:author)
                         :mailto ,(project/main:email)))
              (format t "~&Successfully generated: ~A~%" path)
              t)))
        (format *error-output* "~&File already exists?: ~A~%" path)
        (probe-file path)
        (format *error-output* "~&Fail: ~A~%" path))))

(defun init (params)
  (let* ((name (let ((i (or (first params) "default")))
                 (loop for a across "/\\"
                    do (setf i (remove a i)))
                 i))
         (dir (format nil "~A/" (or (second params) name))))
    (when (probe-file dir)
      (format *error-output* "~&Directory already exists: ~A~%" dir)
      (return-from init nil))
    (ensure-directories-exist dir)
    (ensure-directories-exist (merge-pathnames "src/" dir))
    (ensure-directories-exist (merge-pathnames "t/" dir))
    (unless (and (ignore-errors (prepare-project name dir))
                 (prepare-asd name dir))
      (let ((path (make-pathname :defaults "project" :type "lisp")))
        (format *error-output* "~&Delete: ~A~%" path)
        (delete-file path)))))
