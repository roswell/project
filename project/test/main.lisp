(uiop/package:define-package :project.project.test/main
                             (:nicknames :project.project.test)
                             (:use :project/system :cl) (:shadow)
                             (:export) (:intern))
(in-package :project.project.test/main)
;;;don't edit above

(defun test (&rest argv)
  (setf argv (first argv))
  (cond ((equal (first argv) "-a")
         (let* ((path (find-asd *default-pathname-defaults*))
                (asd (asd path))
                (asd (loop for (i j . rest) on asd :by 'cddr
                        unless #1=(and (eql i :in-order-to)
                                       (consp j)
                                       (consp (first j))
                                       (eql (first (first j)) ($ :test-op)))
                        collect  i
                        unless #1#
                        collect j))
                (asd `(,@asd
                       :in-order-to
                       ((,($ :test-op) (,($ :test-op) ,(format nil "~A/tests" (getf asd :name)))))))
                (rest (getf asd :rest)))
           (when (second argv)
             (push `(,($ :defsystem) ,(format nil "~A/tests" (getf asd :name))
                      :depends-on (,(getf asd :name) "rove")
                      :components ()
                      :perform (,($ :test-op) (,($ :o) ,($ :c))
                                 (,($ :symbol-call) :rove :run ,(getf asd :name))))
                   rest)
             (setf (getf asd :rest) rest))
           (setf (asd path) asd))
         (when (second argv) ;; stub
           
           ))
        ((equal (first argv) "-d")
         )
        (t
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
             (asdf:test-system (asdf:find-system system)))))))
