(in-package #:canginx)

(defparameter *index* "/index.htm" "Home HTML")

(defun @dispose (*client* *root* *buffer*
                 &optional (nth 1)
                 &aux $header $fields $path $url
                   ($length (nth-value 1 (socket-receive *client* *buffer* nil))))
  
  (when (zero? $length)
    ($output "Bye: ~s~%" *client*)
    (return-from @dispose (@close)))
  
  (setf $header (trim (replace-string (flexi-streams:octets-to-string (subseq *buffer* 0 $length)) (string #\Return) ""))
        $fields (split #/\s+/# $header)
        $url (regex-replace "\\?.*$" (second $fields) ""))

  (when (string= $url "/")
    (setf $url *index*))
  (setf $path (string+ *root* $url))
  ($output " ~A [~A] ~% ~A" (first (split "\\n" $header)) (now) *client* :width 103)
  (@log "~A" $header)
  (@compile $path nth)
  (@dispose *client* *root* *buffer* (1+ nth)))

(defun @close ()
  (handler-case
      (socket-close *client*) ;; (socket-shutdown *client* :direction :io)
    (error (e)
      (@error "Shutdown/Close Error: ~A" e))))

(defun start-server (&key port root
                       (log-file "~/log.txt")
                       (log-error "~/error.txt")
                     &aux (server (make-instance 'inet-socket :type :stream :protocol :tcp)))

  (push (list server port root) *servers*)
  (setf *log-file* log-file
        *log-error* log-error)
  (setf (sockopt-reuse-address server) t)
  ;; (setf (non-blocking-mode *server*) t)
  (socket-bind server *address* port)
  (socket-listen server +backlog+)
  (format t "~&Listening :~A~%" port)
  (make-thread
   λ(loop
      (multiple-value-bind (client) ; *peer*)
          (socket-accept server)
        (push client *all-clients*)
        (make-thread '@dispose :arguments (list client root (make-array +buf-size+ :element-type +type+)))))))

