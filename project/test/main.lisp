(uiop/package:define-package :project.project.test/main
                             (:nicknames :project.project.test)
                             (:use :project/system :cl) (:shadow)
                             (:export) (:intern))
(in-package :project.project.test/main)
;;;don't edit above

(defun test (&rest argv)
  (setf argv (first argv))
  (let* ((*default-pathname-defaults* (project/main:work-directory))
         (path (project/main:find-asd *default-pathname-defaults*)))
    (unless argv
      (asdf:load-asd path)
      (unless (uiop:pathname-equal (asdf:system-source-file (asdf:find-system (pathname-name path)))
                                   path)
        (format t "loaded system ~A is differ from system registered ~A~%"
                path
                (asdf:system-source-file (asdf:find-system (pathname-name path))))
        (ros:quit 1))
      (setf argv (list (pathname-name path))))
    (dolist (system argv)
      (format t "~&testing system ~A~%" system)
      (asdf:test-system (asdf:find-system system)))))
