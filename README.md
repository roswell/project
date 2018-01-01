# project

project is a roswell sub command to maitain ``defpackage`` and ``defsystem`` expressions in a project you develop.

## Warning

This software is still ALPHA quality. The APIs will be likely to change.

## Installation

```
ros install roswell/project
```

## Usage by example

### Creating new project 


```
$ ros init project new-project
Successfully generated: new-project/project.lisp
Successfully generated: new-project/new-project.asd
```

if you know asdf ``project.lisp`` seems not important but the file is used for finding asd file. Please keep it if you decide stop using ``project``.

### Adding file to your project

Consider adding a file for the project.

The first step would be preparing a file to add.

```
touch new-project/main.lisp
```

then add the file to the project.

```
ros project add new-project/main.lisp
```

by the command above, ``new-project/new-project.asd`` and ``new-project/main.lisp`` are modified.


```
$ cat new-project/new-project.asd 
;;don't edit
(defsystem "new-project" :class :package-inferred-system :components
 ((:file "main")))
$ cat new-project/main.lisp 
(uiop/package:define-package :new-project/main (:use :cl))
(in-package :new-project/main)
;;;don't edit above
```

### add/remove dependency for the project

```
$ cd new-project
$ ros project depends-on # show depends-on
$ ros project depends-on -a alexandria
$ ros project depends-on
alexandria
$ ros project depends-on -d alexandria
```

### add/remove use package for a file

```
$ ros project depends-on -a alexandria # to depend on system it should be loaded.
$ ros package main.lisp use
cl
$ ros package main.lisp use -a alexandria
$ ros package main.lisp use
alexandria
cl
$ ros package main.lisp use -d alexandria
$ ros package main.lisp use
cl
```

### currently supported commands

```
ros package file export -a/-d symbol*
ros package file nicknames -a/-d symbol*
ros package file shadow -a/-d symbol*
ros package file use -a/-d symbol*

ros project add file*
ros project depends-on -a/-d symbol*
```
