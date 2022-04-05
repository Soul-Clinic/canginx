(in-package #:canginx)

(defconstant +backlog+ 1024)
(defparameter *address* #(0 0 0 0))
(defparameter *servers* ())
(defparameter *all-clients* nil)
(defparameter *client* nil)
(defparameter *root* nil)
(defparameter *buffer* nil)
(defparameter *max-age* 999999)
(defparameter +buf-size+ (* 1024 1024) "1MB buffer")
(defparameter +buf-mini+ (* 1024 5) "At lease 5KB to gzip compress")

(defconst +type+ '(unsigned-byte 8))

