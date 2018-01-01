(uiop/package:define-package :roswell.init.project/main (:use :cl) (:nicknames :roswell.init.project))
(in-package :roswell.init.project/main)
;;;don't edit above
(defvar *loader* '(dolist (n (assoc "asd" data :test 'equal))
                   (funcall (read-from-string "asdf:load-asd")
                            (make-pathname
                             :defaults *load-pathname*
                             :name n
                             :type "asd"))))
(defun prepare-project (names dir)
  (let ((path (merge-pathnames (make-pathname :name "project" :type "lisp") dir)))
    (unless (with-open-file (out path
                                 :direction :output
                                 :if-exists nil
                                 :if-does-not-exist :create)
              (when out
                (let ((*package* (find-package :roswell.init.project)))
                  (format out ";;don't edit~%~(~S~)~%"
                          `(let ((data '(("asd" . ,names))))
                             ,*loader*)))
                (format t "~&Successfully generated: ~A~%" path)
                t))
      (format *error-output* "~&File already exists: ~A~%" path)
      (roswell:quit 1))
    t))

(defun prepare-asd (names dir)
  (loop for name in names
     for path = (merge-pathnames (make-pathname :name name :type "asd") dir)
     always (or (with-open-file (out path
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

(defun project (project &rest names)
  (setf names (list (or (first names) "default"))
        names (mapcar (lambda (name)
                        (setf name (string name))
                        (map () (lambda (i)
                                  (setf name (remove i name)))
                             "/\\")
                        name)
                      names))
  (let ((dir (format nil "~A/" (first names))))
    (when (probe-file dir)
      (format *error-output* "~&Directory already exists: ~A~%" (first names))
      (roswell:quit 1))
    (ensure-directories-exist dir)
    (unless (and (ignore-errors (prepare-project names dir))
                 (prepare-asd names dir))
      (let ((path (make-pathname :defaults "project" :type "lisp")))
        (format *error-output* "~&Delete: ~A~%" path)
        (delete-file path)))))
