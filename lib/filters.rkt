#lang racket/base

(require racket/string
         racket/list
         net/url
         web-server/http/request-structs
         "routing.rkt")

(provide before
         after
         register-before-filter!
         register-after-filter!
         run-before-filters
         run-after-filters)

;; Filter storage
(define before-filters null)
(define after-filters null)

;; Filter registration macros
(define-syntax-rule (before pattern handler)
  (register-before-filter! pattern handler))

(define-syntax-rule (after pattern handler)
  (register-after-filter! pattern handler))

;; Filter registration functions
(define (register-before-filter! pattern handler)
  (set! before-filters
        (append before-filters
                (list (cons pattern handler)))))

(define (register-after-filter! pattern handler)
  (set! after-filters
        (append after-filters
                (list (cons pattern handler)))))

;; Filter execution
(define (run-before-filters req)
  (for ([filter (in-list before-filters)])
    (define pattern (car filter))
    (define handler (cdr filter))
    (when (filter-matches? pattern req)
      (handler req))))

(define (run-after-filters req response)
  (for/fold ([resp response]) ([filter (in-list after-filters)])
    (define pattern (car filter))
    (define handler (cdr filter))
    (if (filter-matches? pattern req)
        (or (handler req resp) resp)
        resp)))

;; Filter pattern matching
(define (filter-matches? pattern req)
  (cond
    [(string? pattern)
     (define pth (apply build-path "/" (map path/param-path (url-path (request-uri req)))))
     (cond
       [(string-contains? pattern ":")
        ; Handle named parameter patterns in filters
        (define-values (pat param-names) (parse-route pattern))
        (and (byte-regexp? pat)
             (regexp-match pat (string->bytes/utf-8 (path->string pth))))]
       [else
        (equal? pattern (path->string pth))])]
    [(symbol? pattern)
     (case pattern
       [(all *) #t]
       [else #f])]
    [(procedure? pattern)
     (pattern req)]
    [else #f]))