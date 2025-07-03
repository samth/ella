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
         web-server/http/response-structs
         racket/string
         )

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
                         #:port 8080
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

(struct route (pat method handler param-names) #:prefab)

(define (register-route! r handler #:method [method #"GET"])
  (define-values (pat param-names) (parse-route r))
  (set! router-tbl
        (append router-tbl
                (list (route pat method handler param-names)))))

(define (parse-route r)
  (define (string->regexp-and-names str)
    (define original-str str)
    (define has-leading-slash (string-prefix? "/" original-str))
    (define cleaned-str (if has-leading-slash (substring original-str 1) original-str))
    (define parts (string-split cleaned-str "/"))

    (define-values (regexp-parts param-names)
      (for/fold ([res '()] [names '()])
                ([part (in-list parts)])
        (if (and (string-length part) (char=? #\: (string-ref part 0)))
            (values (cons "([^/]+)" res)
                    (cons (string->symbol (substring part 1)) names))
            (values (cons (regexp-quote part) res)
                    names))))

    (define joined-regexp-parts (string-join (reverse regexp-parts) "/"))
    (define final-regexp-str
      (string-append (if has-leading-slash "^/" "^")
                     joined-regexp-parts
                     "$"))
    (values (byte-regexp (string->bytes/utf-8 final-regexp-str))
            (reverse param-names)))

  (cond
    [(and (string? r) (string-contains? r ":"))
     (string->regexp-and-names r)]
    [(symbol? r) (values (symbol->string r) '())]
    [(string? r) (values r '())]
    [(byte-regexp? r) (values r '())]
    [else (values r '())]))

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
    (cons r m)))

(define (matches? spec req)
  (define u (request-uri req))
  (define pth (apply build-path "/" (map path/param-path (url-path (request-uri req)))))
  (printf "matches? spec: ~s, pth: ~s\n" (route-pat spec) (path->string pth))
  (and (path-matches? (route-pat spec) pth)
       (method-matches? (route-method spec)
                        (request-method req))))
(define (method-matches? m1 m2)
  (printf "method-matches? m1: ~s, m2: ~s\n" m1 m2)
  (equal? m1 m2))

  
(define (path-matches? spec pth)
  (printf "path-matches? spec: ~s, pth: ~s\n" spec (path->string pth))
  (if (byte-regexp? spec)
      (regexp-match spec (string->bytes/utf-8 (path->string pth)))
      (equal? spec (path->string pth))))

(define (->response r)
  (cond [(string? r) (response/output (λ (o) (write-string r o)))]
        [(bytes? r) (response/output (λ (o) (write-string r o)))]
        [(xexpr? r) (response/xexpr r)]
        [else #f]))

(set-any->response! ->response)

(define (call handler req param-values)
  (if (and (list? param-values) (procedure-arity-includes? handler (add1 (length param-values))))
      (apply handler req param-values)
      (handler req)))

(define current-request (make-parameter #f))
(define current-params (make-parameter (hash)))

(define (req->params req)
  (make-hash (request-bindings req)))

(define-syntax (params stx) #'(current-params))

(define (start req)
  (displayln router-tbl)
  (match (find-route router-tbl req)
    [(cons r mtch) ; r is a route struct
     (let ([handler (route-handler r)]
           [param-names (route-param-names r)]
           [param-values (if (and (list? mtch) (not (null? mtch))) (cdr mtch) '())])
       (parameterize ([current-request req]
                      [current-params
                       (let ([p (req->params req)])
                         (for ([name (in-list param-names)]
                               [val (in-list param-values)])
                           (hash-set! p name (bytes->string/utf-8 val)))
                         p)]))
                         p)])
         (call handler req param-values)))]
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