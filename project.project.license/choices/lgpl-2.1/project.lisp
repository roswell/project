;;don't edit
(let ((data '(("asd" "project.project-license.lgpl-2.1"))))
  (dolist (n (assoc "asd" data :test 'equal))
    (funcall (read-from-string "asdf:load-asd")
             (make-pathname :defaults *load-pathname* :name n :type "asd"))))
