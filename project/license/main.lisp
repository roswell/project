(uiop/package:define-package :project.project.license/main
                             (:nicknames :project.project.license)
                             (:use :project/system :cl) (:shadow) (:export) (:intern))
(in-package :project.project.license/main)
;;don't edit above

(defun license (r)
  (let* ((path (find-asd *default-pathname-defaults*))
         (asd (asd path))
         (f (uiop:symbol-call :project :module "project-license" (first r)))
         (license (when f
                    (apply f (rest r)))))
    (cond ((equal (first r) "-d")
           (remf asd :license)
           (setf (asd path) asd))
          ((first r)
           (setf (getf asd :license) (first r))
           (setf (asd path) asd)
           (let ((file (make-pathname :defaults path
                                      :type nil
                                      :name "LICENSE")))
             (when (and (not (probe-file file))
                        license)
               (format t "~A" license)
               (when (yes-or-no-p "generate ~A?~%" file)
                 (with-open-file (out file :direction :output)
                   (format out "~A" license))))))
          (t
           (format t "ros project license template~%~%License template choices:~%")
           (dolist (path (sort (directory (merge-pathnames "choices/*.*" (asdf:system-source-directory :project.project.license)))
                               #'string< :key (lambda (x) (first (last (pathname-directory path))))))
             (format t " ~A~%" (first (last (pathname-directory path)))))))))
