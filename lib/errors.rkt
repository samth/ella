#lang racket/base

(require racket/hash
         racket/format
         web-server/http/response-structs
         web-server/http/response)

(provide define-error-handler
         error-handler
         default-error-handler
         404-handler
         500-handler)

;; HTTP status codes
(define codes
  (hash 404 #"Not Found"
        500 #"Internal Server Error"
        403 #"Forbidden"
        401 #"Unauthorized"
        200 #"Ok"))

(define (code->msg code)
  (hash-ref codes code #""))

;; Error handler system
(define error-handlers (make-hash))

(define-syntax-rule (define-error-handler code handler)
  (hash-set! error-handlers code handler))

(define (error-handler code req . args)
  (define handler (hash-ref error-handlers code #f))
  (if handler
      (apply handler req args)
      (default-error-handler code req args)))

(define (default-error-handler code req args)
  (response/output #:code code #:message (code->msg code)
                   (λ (o)
                     (write-string (format "Error ~a: ~a" code (code->msg code)) o))))

(define (404-handler req)
  (error-handler 404 req))

(define (500-handler req error-msg)
  (error-handler 500 req error-msg))