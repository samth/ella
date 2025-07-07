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
         web-server/http/bindings
         web-server/http/response
         racket/string
         racket/list
         racket/date
         json
         )

(require (prefix-in r: racket/base))

(provide get post put patch
         params
         first second
         response/json content-type
         html template layout
         before after
         helpers define-helper
         error-handler define-error-handler
         scribble-template
         request-method request-uri url->string current-request current-params
         current-seconds header response-headers response-output response/output
         seconds->date date-month date-day date-year date-hour date-minute format
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
(define before-filters null)
(define after-filters null)

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
        (cond
          [(and (string-length part) (char=? #\: (string-ref part 0)))
           (values (cons "([^/]+)" res)
                   (cons (string->symbol (substring part 1)) names))]
          [(string=? part "*")
           (values (cons "([^/]*)" res)
                   (cons 'splat names))]
          [else
           (values (cons (regexp-quote part) res)
                   names)])))

    (define joined-regexp-parts (string-join (reverse regexp-parts) "/"))
    (define final-regexp-str
      (string-append "^/"
                     joined-regexp-parts
                     "$"))
    (values (byte-regexp (string->bytes/utf-8 final-regexp-str))
            (reverse param-names)))

  (cond
    [(and (string? r) (or (string-contains? r ":") (string-contains? r "*")))
     (string->regexp-and-names r)]
    [(symbol? r) (values (symbol->string r) '())]
    [(string? r) (values r '())]
    [(byte-regexp? r) (values r '())]
    [else (values r '())]))

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

(define (find-route tbl req)
  (for*/first ([r (in-list router-tbl)]
               [m (in-value (matches? r req))]
               #:when m)
    (cons r m)))

(define (matches? spec req)
  (define u (request-uri req))
  (define pth (apply build-path "/" (map path/param-path (url-path (request-uri req)))))
  (printf "matches? spec: ~s, pth: ~s\n" (route-pat spec) (path->string pth))
  (define path-result (path-matches? (route-pat spec) pth))
  (and path-result
       (method-matches? (route-method spec)
                        (request-method req))
       path-result))
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
        [(response? r) r]
        [else #f]))

(struct response (output headers code message) #:prefab)

(define (make-response . args)
  (apply response args))

(define (response/json data)
  (response (λ (o) (write-string (jsexpr->string data) o))
            (list (header #"Content-Type" #"application/json")) 200 #"OK"))

(define (content-type type)
  (case type
    [(json) "application/json"]
    [(html) "text/html"]
    [(text) "text/plain"]
    [(xml) "application/xml"]
    [else (symbol->string type)]))

(define (html xexpr)
  (response/xexpr xexpr))

(define (template name . args)
  (apply (template-function name) args))

(define template-registry (make-hash))

(define (template-function name)
  (hash-ref template-registry name
            (λ () (error 'template "Template not found: ~a" name))))

(define-syntax-rule (define-template name (param ...) body ...)
  (hash-set! template-registry 'name (λ (param ...) body ...)))

(define layout-registry (make-hash))

(define (layout name content . args)
  (apply (layout-function name) content args))

(define (layout-function name)
  (hash-ref layout-registry name
            (λ () (error 'layout "Layout not found: ~a" name))))

(define-syntax-rule (define-layout name (content param ...) body ...)
  (hash-set! layout-registry 'name (λ (content param ...) body ...)))

(provide define-template define-layout)

;; Helper system
(define helper-registry (make-hash))

(define-syntax-rule (define-helper name (param ...) body ...)
  (hash-set! helper-registry 'name (λ (param ...) body ...)))

(define (helper name . args)
  (apply (helper-function name) args))

(define (helper-function name)
  (hash-ref helper-registry name
            (λ () (error 'helper "Helper not found: ~a" name))))

;; Create a helpers namespace that contains all helpers
(define (helpers)
  (define ns (make-hash))
  (for ([(name func) (in-hash helper-registry)])
    (hash-set! ns name func))
  ns)

(provide helper)

;; Scribble template support
(define (scribble-template content)
  "Basic Scribble template support - converts simple markup to HTML"
  (cond
    [(list? content)
     (case (first content)
       [(title) `(h1 ,(scribble-template (second content)))]
       [(section) `(h2 ,(scribble-template (second content)))]
       [(para) `(p ,@(map scribble-template (rest content)))]
       [(bold) `(strong ,(scribble-template (second content)))]
       [(italic) `(em ,(scribble-template (second content)))]
       [(itemlist) `(ul ,@(map (λ (item) `(li ,(scribble-template item))) 
                               (rest content)))]
       [(link) `(a ([href ,(scribble-template (third content))]) 
                   ,(scribble-template (second content)))]
       [else (map scribble-template content)])]
    [else content]))

;; Filter system
(define-syntax-rule (before pattern handler)
  (register-before-filter! pattern handler))

(define-syntax-rule (after pattern handler)
  (register-after-filter! pattern handler))

(define (register-before-filter! pattern handler)
  (set! before-filters
        (append before-filters
                (list (cons pattern handler)))))

(define (register-after-filter! pattern handler)
  (set! after-filters
        (append after-filters
                (list (cons pattern handler)))))

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

(set-any->response! ->response)

(define (call handler req param-values)
  (if (and (list? param-values) (procedure-arity-includes? handler (add1 (length param-values))))
      (apply handler req param-values)
      (handler req)))

(define current-request (make-parameter #f))
(define current-params (make-parameter (hash)))

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

(define-syntax (params stx) #'(current-params))

(define (start req)
  (displayln router-tbl)
  
  (define response
    (match (find-route router-tbl req)
      [(cons r mtch) ; r is a route struct
       (let ([handler (route-handler r)]
             [param-names (route-param-names r)]
             [param-values (if (and (list? mtch) (not (null? mtch))) (cdr mtch) '())])
         (parameterize ([current-request req]
                        [current-params
                         (let ([p (req->params req)])
                           (define splat-values '())
                           (for ([name (in-list param-names)]
                                 [val (in-list param-values)])
                             (if (eq? name 'splat)
                                 (set! splat-values (append splat-values (list (bytes->string/utf-8 val))))
                                 (hash-set! p name (bytes->string/utf-8 val))))
                           (when (not (null? splat-values))
                             (hash-set! p 'splat (if (= (length splat-values) 1)
                                                     (first splat-values)
                                                     splat-values)))
                           p)])
           ; Run before filters with params context
           (run-before-filters req)
           (with-handlers ([exn:fail? (λ (e) (500-handler req (exn-message e)))])
             (call handler req param-values))))]
      [_ 
       ; Run before filters even for 404
       (parameterize ([current-request req]
                      [current-params (req->params req)])
         (run-before-filters req))
       (404-handler req)]))
  
  ; Run after filters and return response
  (run-after-filters req response))

(module+ test
  (require rackunit racket/list racket/promise)
  
  ;; Test route parsing
  (test-case "Route parsing"
    (define-values (pat1 params1) (parse-route "/simple"))
    (check-equal? pat1 "/simple")
    (check-equal? params1 '())
    
    (define-values (pat2 params2) (parse-route "/user/:id"))
    (check-true (byte-regexp? pat2))
    (check-equal? params2 '(id))
    
    (define-values (pat3 params3) (parse-route "/say/*/to/*"))
    (check-true (byte-regexp? pat3))
    (check-equal? params3 '(splat splat)))
  
  ;; Test path matching
  (test-case "Path matching"
    (check-equal? (path-matches? "/simple" (string->path "/simple"))
                  #t)
    (check-equal? (path-matches? "/simple" (string->path "/other"))
                  #f)
    (check-equal? (path-matches? (byte-regexp #"^/user/([^/]+)$") 
                                 (string->path "/user/123"))
                  '(#"/user/123" #"123"))
    (check-equal? (path-matches? (byte-regexp #"^/say/([^/]*)/to/([^/]*)$") 
                                 (string->path "/say/hello/to/world"))
                  '(#"/say/hello/to/world" #"hello" #"world")))
  
  ;; Test route matching
  (test-case "Route matching"
    (define simple-route (route "/simple" #"GET" (lambda (req) "simple") '()))
    (define param-route (route (byte-regexp #"^/user/([^/]+)$") #"GET" (lambda (req) "user") '(id)))
    (define splat-route (route (byte-regexp #"^/say/([^/]*)/to/([^/]*)$") #"GET" (lambda (req) "say") '(splat splat)))
    
    (define (make-test-req path)
      (make-request #"GET" (string->url path) null (delay null) #f "" 80 ""))
    
    (check-equal? (matches? simple-route (make-test-req "/simple"))
                  #t)
    (check-equal? (matches? simple-route (make-test-req "/other"))
                  #f)
    (check-equal? (matches? param-route (make-test-req "/user/123"))
                  '(#"/user/123" #"123"))
    (check-equal? (matches? splat-route (make-test-req "/say/hello/to/world"))
                  '(#"/say/hello/to/world" #"hello" #"world")))
  
  ;; Test parameter handling
  (test-case "Parameter handling"
    (define req-with-query (make-request #"GET" 
                                        (string->url "/test?name=Alice&age=30") 
                                        null (delay null) #f "" 80 ""))
    (define params-hash (req->params req-with-query))
    (check-equal? (hash-ref params-hash 'name) "Alice")
    (check-equal? (hash-ref params-hash 'age) "30"))
  
  ;; Test JSON response
  (test-case "JSON response"
    (define jr (response/json (hash 'name "Alice" 'age 30)))
    (check-true (response? jr)))
  
  ;; Test content-type helper
  (test-case "Content-type helper"
    (check-equal? (content-type 'json) "application/json")
    (check-equal? (content-type 'html) "text/html")
    (check-equal? (content-type 'text) "text/plain")
    (check-equal? (content-type 'custom) "custom"))
  
  ;; Test template registry
  (test-case "Template system"
    (hash-set! template-registry 'test-template 
               (lambda (name) (string-append "Hello, " name "!")))
    (check-equal? (template 'test-template "World") "Hello, World!")
    
    (hash-set! layout-registry 'test-layout
               (lambda (content title) (string-append title ": " content)))
    (check-equal? (layout 'test-layout "Body content" "Page Title") 
                  "Page Title: Body content")))