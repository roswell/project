(uiop/package:define-package :roswell.init.project/main (:use :cl) (:nicknames :roswell.init.project))
(in-package :roswell.init.project/main)
;;;don't edit above
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
                (let ((*package* (find-package :roswell.init.project)))
                  (format out ";;don't edit~%~(~S~)~%"
                          `(let ((data '(("asd" . ,(list name)))))
                             ,*loader*)))
                (format t "~&Successfully generated: ~A~%" path)
                t))
      (format *error-output* "~&File already exists: ~A~%" path)
      (roswell:quit 1))
    t))

(defun prepare-asd (name dir)
  (let ((path (merge-pathnames (make-pathname :name name :type "asd") dir)))
    (or (with-open-file (out path
                             :direction :output
                             :if-exists nil
                             :if-does-not-exist :create)
          (when out
            (format out ";;don't edit~%(defsystem ~S)" name)
            (format t "~&Successfully generated: ~A~%" path)
            t))
        (format *error-output* "~&File already exists?: ~A~%" path)
        (probe-file path)
        (format *error-output* "~&Fail: ~A~%" path))))

(defun project (project &rest params)
  (let* ((name (let ((i (or (first params) "default")))
                 (loop for a across "/\\"
                    do (setf i (remove a i)))
                 i))
         (dir (format nil "~A/" (or (second params) name))))
    (when (probe-file dir)
      (format *error-output* "~&Directory already exists: ~A~%" dir)
      (roswell:quit 1))
    (ensure-directories-exist dir)
    (unless (and (ignore-errors (prepare-project name dir))
                 (prepare-asd name dir))
      (let ((path (make-pathname :defaults "project" :type "lisp")))
        (format *error-output* "~&Delete: ~A~%" path)
        (delete-file path)))))
