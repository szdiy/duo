#! /usr/bin/env racket

;---------------------------------------------------------------------------------------------
; read_dlt645.rkt -- read data from a electricity meter via dlt645 protocol
;
;----------------------
; 2020-01-10
; Atommann
;
; It is used to read the data from the electricity meter and send them to szdiy server
; via the HTTP GET or POST method
;
; Prototyping purpose, the plan is to run this code on a Raspberry pi thus web developer
; can get the real data.
; In the mean time, the firmware coder can write code for ESP8266/ESP32 and the hardware
; designer can make the hardware. When everything is ready we then switch to ESP8266/ESP32.
;
; References
; https://github.com/aixiwang/python_dlt645
;
;---------------------------------------------------------------------------------------------

(require libserialport)
(require simple-http)

;; sleep time, in seconds
(define sleep-time 60)

; the address of the meter in SZDIY hackspace
(define meter-addr (bytes #x95 #x04 #x13 #x00 #x00 #x00))

; the control code for reading
(define ctrl-code-read (bytes #x11))

; when we want to read 4 bytes, use this
(define lens-four (bytes #x04))

; the data tag for "total kWH at this moment"
; TODO need to confirm
(define data-tag-total (bytes #x00 #x01 #x00 #x00))

;-------------------------
; decode_dlt645
;-------------------------

; rPi send: 68 95 04 13 00 00 00 68 11 04 34 33 34 33 5F 16
; response: fe fe fe fe 68 95 04 13 00 00 00 68 91 08 34 33 34 33 bb 44 6c 33 81 16

; (define s (bytes #xfe #xfe #xfe #xfe #x68 #x95 #x04 #x13 #x00 #x00 #x00 #x68 #x91 #x08 #x34 #x33 #x34 #x33 #xbb #x44 #x6c #x33 #x81 #x16))

; https://stackoverflow.com/questions/8092878/racket-output-content-of-a-list
(define (output-list-data-hex list)
  (cond 
    [(null? list) #f]                           ; actually doesn't really matter what we return
    [else (printf "0x~X " (first list))         ; display the first item ...
          (output-list-data-hex (rest list))])) ; and start over with the rest

;-------------------------
; dlt645-rm-fe
; remove the 4 0xfe prefix
;-------------------------
(define (dlt645-rm-fe s)
  (if (bytes=?
        (subbytes s 0 4)
        (make-bytes 4 #xfe))
    (subbytes s 4)
    #""))

(define (decode-dlt645 data)
  (display "pass"))

; atommann
; data[1:7] : is the address
; d_out     : the data we want
; data[8]   : control code

(define (add-0x33h element)
  (+ element #x33))

;-------------------------
; encode-dlt645
;
; TODO
; * use more small functions
;-------------------------
(define (encode-dlt645 addr ctrl-code lens data-tag)
  (let* ([data-tag-temp (list->bytes (map add-0x33h (bytes->list data-tag)))]
         [s1 (bytes-append (bytes #x68) addr (bytes #x68) ctrl-code lens data-tag-temp)]
         [check-sum (bytes (modulo (apply + (bytes->list s1)) 256))]
         [s2 (bytes-append s1 check-sum (bytes #x16))])
    s2))


(define prefix-fe (make-bytes 4 #xfe))

;; send this command to the meter
;; it will send the address back
(define read-addr-cmd (bytes #x68 #xaa #xaa #xaa #xaa #xaa #xaa #x68 #x13 #x00 #xdf #x16)

;-------------------------
; dlt645-get-addr
;-------------------------
(define (dlt645-get-addr serial)
  (display "pass"))

;-------------------------
; dlt645-read-data
;-------------------------    
(define dlt645-read-data(serial addr data-tag)
  (display "pass"))

;(open-serial-port "/dev/ttyUSB0" #:baudrate 2400 #:bits 8 #:parity 'even)

;-------------------------
; dlt645-read-time
;
; The time is encoded in 3 bytes (BCD)
;-------------------------
(define (dlt645-read-time serial addr data-tag)
  (display "pass"))

; Setup a html-request using SSL and pointed at api.szdiy.org
(define api-szdiy-org
  (update-headers
   (update-ssl
    (update-host html-requester "api.szdiy.org.org") #t)
   '("Authorization: 0000")))

; params for the post
(define params '((foo . "12") (bar . "hello")))
 
; Make a POST to https://api.szdiy.org/duo/upload?node=001
(define response (post api-szdiy-org "/" #:params params))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        Application Specific Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; just a place holder
(define (send-command)
  (display "Sent\n"))

;; just a place holder
(define (delay-for-a-while)
  (display "Delayed\n"))

;; just a place holder
(define (receive-result)
  (display "Got data!\n"))

;; just a place holder
(define (post)
  (display "Post done!\n"))

(define (read)
  (send-command)
  (delay-for-a-while)
  (receive-result))

;; read  <-+
;; post    |
;; sleep --+
(define (forever)
  (read)
  (post)
  (sleep sleep-time)
  (forever))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        RUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; List serial ports (sanity check)
(for ((serial-port (in-serial-ports)))
  (printf "found ~a\n" serial-port))

; Connect to serial port
(define-values (in out)
  (open-serial-port "/dev/ttyUSB0" #:baudrate 2400 #:bits 8 #:parity 'even))

;; fire
(forever)
