;;;; package.lisp

(defpackage #:canginx
  (:nicknames :cgx)
  (:use #:cl
        #:celwk
        #:cl-ppcre
        #:salza2
        #:sb-bsd-sockets
        #:sb-thread)
  (:export
   #:start-server))
