(uiop/package:define-package :project/main (:nicknames :project) (:use :cl)
                             (:shadow :package)
                             (:shadowing-import-from :project/package
                              :load-package :normalize-package :save-package
                              :combine-main :import-main)
                             (:shadowing-import-from :project/system :find-asd
                              :asd :ensure-defpackage)
                             (:export :package :find-asd :asd
                              :ensure-defpackage :author :email :work-directory
                              :project :import-main :combine-main :load-package
                              :normalize-package :save-package)
                             (:intern))
(in-package :project/main)
;;don't edit above
(defun author ()
  (remove #\Newline
          (or (ignore-errors (getf (asd (find-asd *default-pathname-defaults*)) :author))
              (ignore-errors (uiop:run-program "git config --global --get user.name" :output :string))
              (ignore-errors (uiop:run-program "whoami" :output :string))
              "Jane Roe")))

(defun email ()
  (remove #\Newline
          (or
           (ignore-errors (getf (asd (find-asd *default-pathname-defaults*)) :mailto))
           (ignore-errors (uiop:run-program "git config --global --get user.email" :output :string))
           (ignore-errors (uiop:run-program "echo $(whoami)@$(hostname)" :output :string))
           "Jane.Roe@example.com")))

(defun module (prefix name)
  "Load external system"
  (and (loop for c across "/\\"
             never (find c name))
       (let ((imp (format nil "project.~A.~A" prefix name)))
         (or #1=(ignore-errors
                 (let (*read-eval*)
                   (read-from-string (format nil "~A::~A" imp name))))
             (progn
               (uiop:symbol-call :ql :register-local-projects)
               (or
                (and (or (uiop:symbol-call :ql-dist :find-system imp)
                         (uiop:symbol-call :ql :where-is-system imp))
                     (uiop:symbol-call :ql :quickload imp :silent t)))
               #1#)))))

(defvar *work-directory* nil)

(defun work-directory (&optional path)
  (setf *work-directory*
        (or (and path (uiop:directory-exists-p path))
            (and path (uiop:file-exists-p path)
                 (equal (pathname-type path) "asd")
                 path)
            (ignore-errors (asdf:system-source-file (asdf:find-system path)))
            *work-directory*
            *default-pathname-defaults*))
  (make-pathname :defaults *work-directory* :type nil :name nil))

(defun project (&rest argv)
  (setf argv (mapcar #'princ-to-string argv))
  (let ((*default-pathname-defaults* (work-directory)))
    (funcall (module "project" (or (first argv) "info"))
             (rest argv))))

(defun package (&rest argv)
  (setf argv (mapcar #'princ-to-string argv))
  (let ((*default-pathname-defaults* (work-directory)))
    (funcall (module "package" (or (second argv) "help"))
             (cons (first argv) (cddr argv)))))

