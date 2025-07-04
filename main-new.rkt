#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/match 
         racket/hash
         racket/string
         racket/list
         racket/date
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
         json
         "lib/routing.rkt"
         "lib/filters.rkt"
         "lib/helpers.rkt"
         "lib/templates.rkt"
         "lib/responses.rkt"
         "lib/errors.rkt"
         "lib/params.rkt")

(require (prefix-in r: racket/base))

;; Core routing
(provide get post put patch head
         
         ;; Parameters 
         params
         
         ;; Responses
         json-response content-type html
         
         ;; Templates and layouts
         template layout define-template define-layout
         scribble-template
         
         ;; Filters
         before after
         
         ;; Helpers
         helper define-helper
         
         ;; Error handling
         error-handler define-error-handler
         
         ;; Utility functions
         current-request current-params
         request-method request-uri url->string
         current-seconds header response-headers response-output response/output
         seconds->date date-month date-day date-year date-hour date-minute format
         
         ;; List utilities (for splat parameters)
         first second
         
         ;; Module system
         (rename-out [-#%module-begin #%module-begin]) 
         (except-out (all-from-out racket/base) #%module-begin))

(module reader syntax/module-reader
  ella/main-new)

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

;; HTTP method macros
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

;; Response handling
(set-any->response! ->response)

;; Simple header constructor
(define (header name value)
  (cons name value))

(define (call handler req param-values)
  (if (and (list? param-values) (procedure-arity-includes? handler (add1 (length param-values))))
      (apply handler req param-values)
      (handler req)))

;; Main request handler
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

;; Export re-provided functions
(provide helper
         define-template define-layout
         router-tbl)