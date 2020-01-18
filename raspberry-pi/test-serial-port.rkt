#lang racket

;; test libserport package

;(require libserialport)
(require serial)

; the address of the meter in SZDIY hackspace
(define meter-addr (bytes #x95 #x04 #x13 #x00 #x00 #x00))

; the control code for reading
(define ctrl-code-read (bytes #x11))

; when we want to read 4 bytes, use this
(define lens-four (bytes #x04))

; the data tag for "total kWH at this moment"
; TODO need to confirm
(define data-tag-total (bytes #x00 #x01 #x00 #x00))

(define prefix-fe (make-bytes 4 #xfe))

;; send this command to the meter
;; it will send the address back
(define read-addr-cmd (bytes #x68 #xaa #xaa #xaa #xaa #xaa #xaa #x68 #x13 #x00 #xdf #x16))

;; If we send the following seq. to meter
;; it will send back the total kWH value:
;; #x0A = \n
;; 68 95 04 13 00 00 00 68 11 04 34 33 34 33 5F 16

(define cmd-read-total (bytes #x68 #x95 #x04 #x13 #x00 #x00 #x00 #x68 #x11 #x04 #x34 #x33 #x34 #x33 #x5F #x16 #x0A))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Reading data
(define BUFFER-SIZE 20000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        RUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; List serial ports (sanity check)
;(for ((serial-port (in-serial-ports)))
;  (printf "found ~a\n" serial-port))

; serial port parameters
(define baudrate 2400)
(define parity 'even)

; Connect to serial port
(define-values (in out)
  (open-serial-port
    "/dev/ttyUSB0"
    #:baudrate 2400
    #:bits 8
    #:parity 'even
    #:stopbits 1))

(display cmd-read-total)
(write-bytes cmd-read-total out)
(flush-output out)

(define read-buffer (make-bytes BUFFER-SIZE))

;(define read-result (read-bytes-avail!* read-buffer in))

;; byte->integer : Byte -> Integer
;; Convert a byte to an integer
(define (byte->integer b)
  (first (bytes->list b)))

(sleep 0.1)

(read-bytes 10 in)

;(display (read-bytes 10 in))

;(read-bytes 1 in)
;(drain-port in)
;(display (read-bytes 24 in))

;(close-serial-port "/dev/ttyUSB0")

