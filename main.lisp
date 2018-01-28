(uiop/package:define-package :project/main (:nicknames :project :roswell.project) (:use :cl)
                             (:shadow) (:export :find-asd :asd :ensure-defpackage :author :email :work-directory :pkg :project)
                             (:intern))
(in-package :project/main)
;;don't edit above
(defun find-asd (dir)
  (let* ((prj (loop
                 :for path := (make-pathname
                               :defaults dir
                               :name "project"
                               :type "lisp")
                 :when (probe-file path)
                 :do (return path)
                 :when (equal (ignore-errors (pathname-directory (truename dir))) '(:absolute))
                 :do (return nil)
                 :do (setf dir (uiop:pathname-parent-directory-pathname dir))))
         (*read-eval*)
         (name (with-open-file (in prj)
                 (second (assoc "asd" (second (second (first (second (read in)))))
                              :test 'equal)))))
    (probe-file (make-pathname :defaults prj :name name :type "asd"))))

(defun asd (path)
  (when path
    (with-open-file (in path)
      (with-standard-io-syntax
        (in-package :project/main)
        (let* ((*read-eval*)
               (asd (read in)))
          (assert (eql (first asd) 'defsystem))
          (cons :name (cdr asd)))))))

(defun (setf asd) (asd path)
  (when path
    (let* ((asd (copy-list asd))
           (name (getf asd :name)))
      (assert name)
      (remf asd :name)
      (with-open-file (out path
                           :direction :output
                           :if-exists :supersede)
        (let* ((*package* (find-package :project/main)))
          (format out ";;don't edit~%~S"
                  `(defsystem ,name
                     ,@asd))))))
  asd)

(defun ensure-defpackage (name file)
  (let ((1stexp (with-open-file (in file)
                  (let (*read-eval*)
                    (ignore-errors (read in))))))
    (unless (eql (first 1stexp) 'uiop:define-package)
      (let* ((content (with-open-file (stream file)
                        (let ((seq (make-array (file-length stream)
                                               :element-type 'character
                                               :fill-pointer t)))
                          (setf (fill-pointer seq) (read-sequence seq stream))
                          seq)))
             (package (read-from-string (format nil ":~A" name))))
        (with-open-file (out file
                             :direction :output
                             :if-exists :supersede)
          (format out "~(~S~%~S~%~);;;don't edit above~%~A"
                  `(uiop:define-package ,package
                       (:use :cl))
                  `(in-package ,package)
                  content))))))

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
       (let ((imp (format nil "roswell.~A.~A" prefix name)))
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

(defun project (&rest argv)
  (setf argv (mapcar #'princ-to-string argv))
  (funcall (module "project" (or (first argv) "info"))
           (rest argv)))

(defun pkg (&rest argv)
  (setf argv (mapcar #'princ-to-string argv))
  (funcall (module "package" (or (second argv) "help"))
           (cons (first argv) (cddr argv))))

(defvar *work-directory* nil)

(defun work-directory (&optional path)
  (setf *work-directory*
        (or (and path (uiop:directory-exists-p path))
            *work-directory*
            *default-pathname-defaults*)))

