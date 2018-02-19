(DEFPACKAGE :ROSWELL.INIT.AUTOCONF
  (:USE :CL))
(IN-PACKAGE :ROSWELL.INIT.AUTOCONF)
(DEFVAR *PARAMS*
  '(:FILES
    ((:NAME "template.ros" :METHOD "djula" :REWRITE
      "{{name}}/roswell/{{name}}.ros")
     (:NAME "bootstrap" :METHOD "copy" :CHMOD "755" :REWRITE
      "{{name}}/bootstrap")
     (:NAME "Makefile.am" :METHOD "djula" :REWRITE "{{name}}/Makefile.am")
     (:NAME "configure.ac" :METHOD "djula" :REWRITE "{{name}}/configure.ac"))))
(DEFUN AUTOCONF (_ &REST R)
  (ASDF/OPERATE:LOAD-SYSTEM :ROSWELL.UTIL.TEMPLATE :VERBOSE NIL)
  (FUNCALL (READ-FROM-STRING "roswell.util.template:template-apply") _ R
           *PARAMS*))
