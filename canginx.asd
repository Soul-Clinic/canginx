;;;; canginx.asd

(asdf:defsystem #:canginx
  :description "Describe canginx here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:celwk
               #:cl-ppcre
               #:salza2
               #:flexi-streams)
  :components ((:file "package")
               (:file "constant")
               (:file "compile")
               (:file "canginx")))
