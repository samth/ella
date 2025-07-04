#lang racket/base

(require racket/string
         json
         web-server/http/response-structs
         web-server/http/response
         xml
         web-server/http/xexpr)

(provide json-response
         json-response?
         json-response->response
         content-type
         ->response)

;; JSON response support
(struct json-response (data) #:transparent)

(define (json-response->response jr)
  (response/output
   #:headers (list (cons #"Content-Type" #"application/json"))
   (λ (o) (write-string (jsexpr->string (json-response-data jr)) o))))

;; Content-type helper
(define (content-type type)
  (case type
    [(json) "application/json"]
    [(html) "text/html"]
    [(text) "text/plain"]
    [(xml) "application/xml"]
    [else (symbol->string type)]))

;; Response conversion
(define (->response r)
  (cond [(string? r) (response/output (λ (o) (write-string r o)))]
        [(bytes? r) (response/output (λ (o) (write-string r o)))]
        [(xexpr? r) (response/xexpr r)]
        [(json-response? r) (json-response->response r)]
        [else #f]))