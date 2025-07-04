#lang racket/base

(require racket/hash
         racket/string
         racket/match
         net/url
         web-server/http/request-structs
         web-server/http/bindings)

(provide current-request
         current-params
         params
         req->params)

;; Parameter handling
(define current-request (make-parameter #f))
(define current-params (make-parameter (hash)))

(define-syntax-rule (params) (current-params))

(define (req->params req)
  (define h (make-hash))
  ; Add POST body parameters and URL query parameters from request-bindings
  (for ([binding (in-list (request-bindings req))])
    (match binding
      [(cons key value)
       (hash-set! h (cond
                        [(bytes? key) (string->symbol (bytes->string/utf-8 key))]
                        [(string? key) (string->symbol key)]
                        [else key])
                  (if (bytes? value)
                      (bytes->string/utf-8 value)
                      value))]))
  ; Add URL query parameters from the URI
  (define uri (request-uri req))
  (when (url-query uri)
    (for ([query-pair (in-list (url-query uri))])
      (hash-set! h (cond
                       [(string? (car query-pair)) (string->symbol (car query-pair))]
                       [(symbol? (car query-pair)) (car query-pair)]
                       [else (car query-pair)])
                 (or (cdr query-pair) ""))))
  h)