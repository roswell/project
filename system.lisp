(uiop/package:define-package :project/system (:use :cl)(:export :find-asd
                              :asd :ensure-defpackage))
(in-package :project/system)
;;;don't edit above
(defun find-asd (dir)
  (let ((wd (symbol-value (uiop:find-symbol* :*work-directory* :project/main))))
    (if (ignore-errors (equal (pathname-type wd) "asd"))
        wd
        (let* ((prj (loop
                       :for path := (make-pathname
                                     :defaults dir
                                     :name "project"
                                     :type "lisp")
                       :for asd := (make-pathname :defaults path :type "asd")
                       :when (probe-file asd)
                       :do (return-from find-asd asd)
                       :when (probe-file path)
                       :do (return path)
                       :when (equal (ignore-errors (pathname-directory (truename dir))) '(:absolute))
                       :do (return nil)
                       :do (setf dir (uiop:pathname-parent-directory-pathname dir))))
               (*read-eval*)
               (name (when prj
                       (with-open-file (in prj)
                         (second (assoc "asd" (second (second (first (second (read in)))))
                                        :test 'equal))))))
          (if name
              (probe-file (make-pathname :defaults prj :name name :type "asd"))
              nil)))))

(defun asd (path)
  (when path
    (with-open-file (in path)
      (with-standard-io-syntax
        (let* ((*read-eval*)
               (*package* (find-package :asdf-user))
               (asd (read in))
               (rest (loop for exp = (read in nil nil)
                        while exp
                        collect exp)))
          (assert (eql (first asd) 'asdf:defsystem))
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
          (format out ";;don't edit~%~S~%"
                  `(defsystem ,name
                     ,@asd))
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
