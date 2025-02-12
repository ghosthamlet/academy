(in-package :academy)

(defun asdf-system-base-path (system-name)
  "Return the root directory of asdf system named NAME."
  (directory-namestring (asdf:component-pathname (asdf:find-system system-name))))

(defun data-path (name &key (verify t))
  "Return the path to the data file named NAME. If VERIFY is T, the existence of
this file is verified."
  (let ((path (format nil "~Adata/~A" (asdf-system-base-path :academy) name)))
    (when (and verify (not (probe-file path)))
      (error "No data file named ~S found." path))
    path))

;;; Attention Hackers! Exercise is good for the heart!
;;;
;;;   Add support for submodules to ASDF-LISP-FILES.

(defun asdf-lisp-files (system-name)
  "Return a list of the lisp files in an ASDF package in the order they would be loaded.
!!! Note that submodules are not yet supported."
  (mapcar
   #'asdf:component-pathname
   (remove-if-not (lambda (module) (typep module 'asdf:cl-source-file))
                  (asdf:module-components (asdf:find-system system-name)))))

(defmacro with-output-to-file ((filename &optional (if-exists :supersede)) &body body)
  `(with-open-file (*standard-output* ,filename :direction :output :if-exists ,if-exists
                                                :if-does-not-exist :create)
     ,@body))

(defmacro with-output-to-data-file (filename &body body)
  (let ((bytes (gensym))
        (name (gensym)))
    `(let (,bytes (,name (data-path ,filename :verify nil)))
       (with-output-to-file (,name)
         (prog1
             (progn ,@body)
           (setf ,bytes (file-position *standard-output*))))
       (format t "~A bytes written to ~S~%" ,bytes ,name))))