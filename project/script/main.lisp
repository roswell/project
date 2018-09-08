(uiop/package:define-package :project.project.script/main
                             (:nicknames :project.project.script)
                             (:use :project/system :cl) (:shadow) (:export)
                             (:intern))
(in-package :project.project.script/main)
;;don't edit above

(defun script (r)
  (let ((*default-pathname-defaults*
          (ensure-directories-exist
           (merge-pathnames "roswell/" (make-pathname :defaults  (project/system:find-asd ".") :name nil :type nil)))))
    #+sbcl(sb-posix:chdir *default-pathname-defaults*)
    (dolist (e r)
      (funcall (roswell.util:module "init" "default")
               (file-namestring e)
               "lib" (pathname-name (project/system:find-asd "."))))))

