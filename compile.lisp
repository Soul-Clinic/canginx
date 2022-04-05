(in-package #:canginx)

;; Content-Disposition: attachment; filename=Leovinci.webp~%~	For Download File
(defparameter *server-header-format* "HTTP/1.1 200 OK~%~
  Access-Control-Allow-Origin: *~%~
  Connection: keep-alive~%~
  Content-Encoding: ~A~%~
  Keep: ~A~%~
  Port: ~A~%~
  Cache-Control: max-age=~A~%~
  Content-Type: ~A~%~
  Content-Length: ~A~2%")

(defun make-header (encoding nth port type length)
  (fmt *server-header-format* encoding nth port *max-age* type length))

(defun @compile (path nth
                 &aux type binary?
                   (port (second-value (ignore-errors (socket-peername *client*)))))
  "Maybe cache them, clone *buffer* for each file??"
  
  (cond ((scan "js$" path)
         (setf type "application/javascript"))
        ((scan "css$" path)
         (setf type "text/css"))
        ((scan "ttf$" path)
         (setf type "application/octet-stream"))
        ((scan "(jpe?g|png|webp|ico)$" path)
         (setf type #/image/$(elt (nth-value 1 (scan-to-strings "\\.(\\w+)$" path)) 0)/#
               binary? t))
        (:default
         (setf type "text/html")))

  (with-open-file (in path :element-type +type+)

    (cond ((or binary? (< (file-length in) +buf-mini+))
           (let ((header (make-header :nope nth port type (file-length in))))
             (socket-send *client* header (length header))
             (loop
               (let ((position (read-sequence *buffer* in)))
                 (when (zero? position)
                   (return))
                 (handler-case
                     (socket-send *client* *buffer* position)
                   (error (e)
                     ($output "SOCKET-SEND error: ~A" e)
                     (return)))))))
          (:otherwise          
           (let* ((buff (make-array (file-length in) :element-type '(unsigned-byte 8)))
                  (_ (read-sequence buff in))
                  (data (compress-data buff 'gzip-compressor))
                  (header (make-header :gzip nth port type (length data))))
             (socket-send *client* header (length header))             
             (socket-send *client* data (length data)))))))

