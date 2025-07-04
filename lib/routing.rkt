#lang racket/base

(require racket/match
         racket/string
         racket/list
         net/url
         web-server/http/request-structs)

(provide route
         route-pat route-method route-handler route-param-names
         register-route!
         parse-route
         find-route
         matches?
         path-matches?
         method-matches?
         router-tbl)

;; Route data structure
(struct route (pat method handler param-names) #:prefab)

;; Route registration
(define router-tbl null)

(define (register-route! r handler #:method [method #"GET"])
  (define-values (pat param-names) (parse-route r))
  (set! router-tbl
        (append router-tbl
                (list (route pat method handler param-names)))))

;; Route parsing
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

;; Route matching
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