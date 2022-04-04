(in-package #:canginx)

(defun @compile (path nth key
                 &aux type binary?)
  "Maybe cache them, copy the *buffer*"
  
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
           (let ((header (input *server-header-format*
                                "Nope" nth key type
                                (file-length in))))
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
                  (header (input *server-header-format*
                                 "gzip" nth key type
                                 (length data))))
             (socket-send *client* header (length header))             
             (socket-send *client* data (length data)))))))

