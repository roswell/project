(uiop/package:define-package :project/system (:use :cl)(:export :find-asd
                              :asd :ensure-defpackage :$ :*type-keyword-assoc*))
(in-package :project/system)
;;;don't edit above
(defvar *type-keyword-assoc*
  '(("lisp" :file)))

(defun find-asd (dir)
  (let ((wd (symbol-value (uiop:find-symbol* :*work-directory* :project/main))))
    (if (ignore-errors (equal (pathname-type wd) "asd"))
        wd
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
               (prj/ (when prj (second (second (first (second (uiop:read-file-form prj)))))))
               (name (when prj/ (second (assoc "asd" prj/ :test 'equal)))))
          (values
           (if name
               (probe-file (make-pathname :defaults prj :name name :type "asd"))
               nil)
           prj/)))))

(defun $ (name)
  (intern (format nil "~A" name) (find-package :project/system)))

(defun asd (path)
  (when path
    (with-open-file (in path)
      (with-standard-io-syntax
        (let* ((*read-eval*)
               (*package* (find-package :project/system))
               (asd (read in))
               (rest (loop for exp = (read in nil nil)
                        while exp
                        collect exp)))
          (assert (eql (first asd) 'project/system::defsystem))
          `(:name ,(second asd)
                  ,@(cddr asd)
                  :rest ,rest))))))

(defun (setf asd) (asd path)
  (when path
    (let* ((asd (copy-list asd))
           (name (getf asd :name))
           (rest (getf asd :rest)))
      (assert name)
      (remf asd :name)
      (remf asd :rest)
      (with-open-file (out path
                           :direction :output
                           :if-exists :supersede)
        (let* ((*package* (find-package :project/system)))
          (format out ";;don't edit~%")
          (format out "(defsystem ~S" name)
          (loop for (key val) on asd by #'cddr
                do (format out "~%  ~(~S~) ~A" key
                           (cond ((keywordp val)
                                  (format nil "~(~S~)" val))
                                 (t (format nil "~S" val)))))
          (format out ")~%")
          (format out "~{~S~^~%~}"
                  (mapcar (lambda (x)
                            (if (eql (first x) 'asdf:defsystem)
                                `(defsysem ,@(rest x))
                                x))
                          rest))))))
  asd)

(defun ensure-defpackage (name file)
  (let ((1stexp (with-open-file (in file)
                  (let (*read-eval*)
                    (ignore-errors (read in))))))
    (unless (and (consp 1stexp)
                 (eql (first 1stexp)
                      'uiop:define-package))
      (let* ((content (uiop:read-file-string file))
             (package (read-from-string (format nil ":~A" name))))
        (with-open-file (out file
                             :direction :output
                             :if-exists :supersede)
          (format out "~(~S~%~S~%~);;;don't edit above~%~A"
                  `(uiop:define-package ,package
                       (:use :cl))
                  `(in-package ,package)
                  content))))
    (unless (eql (second 1stexp)
                 (read-from-string (format nil ":~A" name)))
      (let* ((content (uiop:read-file-lines file))
             (package (read-from-string (format nil ":~A" name))))
        (with-open-file (out file
                             :direction :output
                             :if-exists :supersede)
          (format out "~(~S~%~S~%~);;;don't edit above~%"
                  `(uiop:define-package ,package
                       (:use :cl))
                  `(in-package ,package))
          (loop with write = nil
             for line in content
             when write
             do (format out "~A~%" line)
             when (equal ";;;don't edit above" line)
             do (setf write t)))))))
