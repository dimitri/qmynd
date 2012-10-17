;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                  ;;;
;;; Free Software published under an MIT-like license. See LICENSE   ;;;
;;;                                                                  ;;;
;;; Copyright (c) 2012 Google, Inc.  All rights reserved.            ;;;
;;;                                                                  ;;;
;;; Original author: Alejandro Sedeño                                ;;;
;;;                                                                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :mysqlnd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 15.6.3 command-initialize-database -- change the default schema

;; We don't actually receive this packet as a client, but it looks like this.

;; (define-packet command-initialize-database
;;   ((tag :mysql-type (integer 1) :value +mysql-command-initialize-database+ :transient t :bind nil)
;;    (schema-name :mysql-type (string :eof))))

;; Returns OK or ERR packet

(defun send-command-initialize-database (schema-name)
  (with-mysql-connection (c)
    (mysql-command-init c +mysql-command-initialize-database+)
    (let ((s (flexi-streams:make-in-memory-output-stream :element-type '(unsigned-byte 8))))
      (write-byte +mysql-command-initialize-database+ s)
      (write-sequence (babel:string-to-octets schema-name) s)
      (mysql-write-packet (flexi-streams:get-output-stream-sequence s)))
    (let ((response (parse-response (mysql-read-packet))))
      (assert (typep
               response
               'response-ok-packet))
      (setf (mysql-connection-default-schema c) schema-name)
      (values))))