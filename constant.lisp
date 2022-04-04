(in-package #:canginx)

(defconstant +backlog+ 1024)
(defparameter *address* #(0 0 0 0))
(defparameter *servers* ())
(defparameter *all-clients* nil)
(defparameter *client* nil)
(defparameter *root* nil)
(defparameter *buffer* nil)
(defparameter +buf-size+ (* 1024 1024) "1MB buffer")
(defparameter +buf-mini+ (* 1024 5) "At lease 5KB to gzip compress")

(defconst +type+ '(unsigned-byte 8))

;;   Content-Disposition: attachment; filename=Leovinci.webp~%~
(defparameter *server-header-format* "HTTP/1.1 200 OK~%~
  Content-Encoding: ~A~%~
  Access-Control-Allow-Origin: *~%~
  Keep: ~A~%~
  Port: ~A~%~
  Connection: keep-alive~%~
  Cache-Control: max-age=300000~%~
  Content-Type: ~A~%~
  Content-Length: ~A~2%")
