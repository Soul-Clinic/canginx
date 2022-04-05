(in-package #:canginx)

(defparameter *log-file* nil)
(defparameter *log-error* nil)
(defun @log (fmt &rest args)
  (with-open-file (*standard-output* *log-file*
                                     :direction :output
                                     :if-does-not-exist :create
                                     :if-exists :append)
    (format t "[~A] ~A" (ip *client*) (now))
    (apply #'$output fmt :width 100 args)
    (write-char #\Newline)))

(defun @error (&rest args)
  (let1 (*log-file* *log-error*)
    (apply #'@log args)))

(defun check-log (&optional (file *log-file*) (lines 100))
  (cmd #/tail -n $lines $file/# t)
  (values))

