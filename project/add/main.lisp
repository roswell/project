(uiop/package:define-package :project.project.add/main
                             (:nicknames :project.project.add)
                             (:use :project :cl) (:shadow) (:export) (:intern))
(in-package :project.project.add/main)
;;don't edit above
(defvar *type-keyword-assoc*
  '(("lisp" :file)))
(defvar *package-infered-system* t)

(defun components-insert (components path name type &optional processed)
  (setf components (copy-list components))
  (let (pos)
    (when (and path *package-infered-system*)
      (setf name (format nil "~{~A/~}~A" path name)
            path nil))
    (cond
      ((and path
            (setf pos (position-if (lambda (x)
                                     (and (eql (first x) :module)
                                          (equal (second x) (first path))))
                                   components)))
       (setf (nth pos components)
             (let ((new (nth pos components)))
               #1=`(:module ,(first path)
                            :components ,(components-insert (getf new :components)
                                                            (rest path)
                                                            name
                                                            type
                                                            (cons (first path) processed)))))
       components)
      (path
       (let ((new ()))
         (cons #1# components)))
      ((find-if (lambda (x)
                  (and (eql (first x) type)
                       (equal (second x) name)))
                components)
       (format *error-output* "already exist ~A" name)
       (error ""))
      (t
       (cons (list type name) components)))))
#|
(components-insert '() '() "test" :FILE) => ((:FILE "test"))
(components-insert '((:FILE "main1")) nil "main2" :FILE) 
=> ((:FILE "main2") (:FILE "main1"))
(components-insert '((:FILE "a")
                     (:module "hoge"
                      :components ((:FILE "a")
                                   (:module "hige"
                                            :components ((:FILE "a")(:FILE "b")))
                                   (:FILE "b")))
                     (:FILE "b"))
                   '("hoge" "hige") "test" :FILE)
=> ((:FILE "a")
    (:MODULE "hoge" :COMPONENTS
             ((:FILE "a")
              (:MODULE "hige" :COMPONENTS ((:FILE "test") (:FILE "a") (:FILE "b")))
              (:FILE "b")))
    (:FILE "b"))
(components-insert '() '("hoge" "hige") "test" :FILE)
=> ((:MODULE "hoge" :COMPONENTS ((:MODULE "hige" :COMPONENTS ((:FILE "test"))))))
(components-insert '((:FILE "main")) '("hoge" "hige") "test" :FILE)
=> ((:MODULE "hoge" :COMPONENTS ((:MODULE "hige" :COMPONENTS ((:FILE "test")))))
    (:FILE "main"))
|#

(defun add-file (file &optional asd asd-path)
  (unless (setq file (probe-file file))
    (error "file not found ~A~%" file))
  (let* ((asd-path (or asd-path (find-asd file)))
         (asd (or asd (asd asd-path)))
         dir)
    (unless asd-path
      (error "can't find asd~%"))
    (setf dir (make-pathname :defaults asd-path :type nil :name nil))
    (setf (getf asd :components)
          (components-insert
           (getf asd :components)
           (subseq (pathname-directory file) (length (pathname-directory dir)))
           (pathname-name file)
           (second (assoc (pathname-type file) *type-keyword-assoc* :test 'equal))))
    (let ((relative (subseq (pathname-directory file) (length (pathname-directory dir)))))
      (when (and (equal (pathname-type file) "lisp")
                 *package-infered-system*)
        (ensure-defpackage (format nil "~A/~{~A/~}~A"
                                   (getf asd :name)
                                   relative
                                   (pathname-name file))
                           file)))
    (values asd asd-path)))


(defun add (r)
  (if r
      (let (asd asd-path)
        (dolist (file r)
          (when (and asd-path
                     (not (equal asd-path (find-asd file))))
            (error "~A is not insert in same project." file))
          (multiple-value-setq (asd asd-path)
            (add-file file asd asd-path)))
        (when *package-infered-system*
          (setf (getf asd :class) :package-inferred-system))
        (setf (asd asd-path) asd))))
