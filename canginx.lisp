(in-package #:canginx)

(defparameter *index* "/index.htm" "Home HTML")

(defun @dispose (*client* *root* *buffer*
                       &optional (nth 1)
                       &aux (key (second-value (ignore-errors (socket-peername *client*)))))
  ($output "~%~A => ~A" nth *client*)
  
  (let* (($length (nth-value 1 (socket-receive *client* *buffer* nil)))
         $header $fields $path $url)
    
    (when (zero? $length)
      ($error "Bye: ~s~%" *client*)
      (return-from @dispose (@close)))
    
    (setf $header (replace-string (flexi-streams:octets-to-string (subseq *buffer* 0 $length)) (string #\Return) "")
          $fields (split #/\s+/# $header)
          $url (regex-replace "\\?.*$" (second $fields) ""))

    (when (string= $url "/")
      (setf $url *index*))
    (setf $path (string+ *root* $url))    
    ($output "~A" $header)

    (@compile $path nth key)
    (@dispose *client* *root* *buffer* (1+ nth))))

(defun @close ()
  (handler-case
      (progn
        (socket-shutdown *client* :direction :io)
        (socket-close *client*))
    (error (e)
      ($output "Shutdown/Close Error: ~A" e))))

(defun start-server (&key port root
                     &aux (server (make-instance 'inet-socket :type :stream :protocol :tcp)))

  (push (list server port root) *servers*)

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

