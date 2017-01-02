#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/match racket/hash
         web-server/servlet-env
         web-server/servlet
         web-server/servlet/servlet-structs
         web-server/dispatch
         net/url
         xml
         web-server/http/xexpr
         web-server/http/request-structs
         web-server/http/response-structs)

(require (prefix-in r: racket/base))

(provide get post put patch
         params
         (rename-out [-#%module-begin #%module-begin]) (except-out (all-from-out racket/base) #%module-begin))

(module reader syntax/module-reader
  ella/main)

(define-syntax (-#%module-begin stx)
  (syntax-parse stx
    [(_ forms ...)
     #'(#%module-begin
        forms ...
        (module+ main
          (serve/servlet start
                         #:servlet-path "/"
                         #:servlet-regexp #rx""
                         #:stateless? #f
                         #:launch-browser? #f)))]))


(define router-tbl null)

(define-syntax-rule (get . args) (route! #"GET" . args))
(define-syntax-rule (post . args) (route! #"POST" . args))
(define-syntax-rule (patch . args) (route! #"PATCH" . args))
(define-syntax-rule (head . args) (route! #"HEAD" . args))
(define-syntax-rule (put . args) (route! #"PUT" . args))

(define-syntax (route! stx)
  (syntax-parse stx
    #:literals (lambda)
    [(_ method route (lambda args body ...))
     #'(register-route! 'route (lambda args body ...) #:method method)]
    [(_ method route e)
     #'(route! method route (lambda _ e))]))

(struct route (pat method handler) #:prefab)

(define (register-route! r handler #:method [method #"GET"])
  (set! router-tbl
        (append router-tbl
                (list (route (parse-route r) method handler)))))

(define (parse-route r)
  (cond [(symbol? route)
         (symbol->string r)]
        [else r]))

(define codes
  (hash 404 #"Not Found"
        200 #"Ok"))

(define (code->msg code)
  (hash-ref codes code #""))

(define (404-handler req)
  (response/output #:code 404 #:message (code->msg 404)
                   (λ (o)
                     (write-string "Not Found" o))))

(define (find-route tbl req)
  (for*/first ([r (in-list router-tbl)]
               [m (in-value (matches? r req))]
               #:when m)
    (cons (route-handler r) m)))

(define (matches? spec req)
  (define u (request-uri req))
  (define pth (simplify-path
               (apply build-path "/" (map path/param-path (url-path u)))
               #f))
  (printf "~s ~s\n" spec pth)
  (and (path-matches? (route-pat spec) pth)
       (method-matches? (route-method spec)
                        (request-method req))))
(define (method-matches? m1 m2)
  (printf "~s ~s\n" m1 m2)
  (equal? m1 m2))

  
(define (path-matches? spec pth)
  (if (regexp? spec)
      (regexp-match spec pth)
      (equal? spec (path->string pth))))

(define (->response r)
  (cond [(string? r) (response/output (λ (o) (write-string r o)))]
        [(bytes? r) (response/output (λ (o) (write-string r o)))]
        [(xexpr? r) (response/xexpr r)]
        [(and (procedure? r)) (response/output r)]
        [else #f]))

(set-any->response! ->response)

(define (call handler req mtch)
  (if (and (list? mtch) (procedure-arity-includes? handler (add1 (length mtch))))
      (apply handler req mtch)
      (handler req)))

(define current-request (make-parameter #f))
(define current-params (make-parameter (hash)))

(define (req->params req)
  (define h1 (make-hash (request-bindings req)))
  (hash-union! h1 (make-hash (request-headers req)))
  h1)

(define-syntax (params stx) #'(current-params))

(define (start req)
  (displayln router-tbl)
  (match  (find-route router-tbl req)
    [(cons handler mtch)
     (parameterize ([current-request req]
                    [current-params (req->params req)])
       (call handler req mtch))]
    [_ (404-handler req)]))

(module+ test
  (require rackunit racket/list racket/promise)
  (define tbl (list (route "/x" #"GET" 1)
                    (route #rx"/" #"GET" 2)))
  (define (req p)
    (make-request #"GET" (string->url p) null (delay null) #f "" 80 ""))
  (check-equal? (path-matches? (route-pat (first tbl))
                               (string->path "/x"))
                #t)
  (check-equal? (matches? (first tbl) (req "/x"))
                #t)


  )
