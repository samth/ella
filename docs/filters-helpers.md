# Filters and Helpers

## Filters

Filters allow you to run code before and after request processing, enabling cross-cutting concerns like authentication, logging, and response modification.

## Before Filters

Before filters run before route handlers are executed.

### Global Before Filters

```racket
(before 'all (lambda (req)
  (printf "Request: ~a ~a\n" 
          (request-method req)
          (url->string (request-uri req)))))
```

### Route-Specific Before Filters

```racket
(before "/admin/*" (lambda (req)
  (unless (authenticated?)
    (error "Unauthorized"))))

(before "/api/*" (lambda (req)
  (hash-set! (current-params) 'api-version "v1")))
```

### Named Parameter Filters

```racket
(before "/users/:id" (lambda (req)
  (define user-id (hash-ref (current-params) 'id))
  (define user (find-user user-id))
  (unless user
    (error "User not found"))
  (hash-set! (current-params) 'user user)))
```

## After Filters

After filters run after route handlers and can modify responses.

### Adding Headers

```racket
(after 'all (lambda (req resp)
  (response/output 
    #:headers (cons (header #"X-Powered-By" #"Ella-Framework")
                   (response-headers resp))
    (response-output resp))))
```

### Response Logging

```racket
(after 'all (lambda (req resp)
  (printf "Response: ~a\n" (response-code resp))
  resp))
```

### CORS Headers

```racket
(after "/api/*" (lambda (req resp)
  (response/output
    #:headers (append (list (header #"Access-Control-Allow-Origin" #"*")
                           (header #"Access-Control-Allow-Methods" #"GET,POST,PUT,DELETE"))
                     (response-headers resp))
    (response-output resp))))
```

## Authentication Example

```racket
(define (authenticated?)
  (hash-has-key? (current-params) 'user))

(before "/admin/*" (lambda (req)
  (unless (authenticated?)
    (error-handler 401 req))))

(before 'all (lambda (req)
  (define session-id (hash-ref (current-params) 'session-id #f))
  (when session-id
    (define user (find-user-by-session session-id))
    (when user
      (hash-set! (current-params) 'user user)))))
```

## Helpers

Helpers are reusable functions that can be used in templates and route handlers.

## Defining Helpers

### Text Helpers

```racket
(define-helper truncate (text max-length)
  (if (> (string-length text) max-length)
      (string-append (substring text 0 (- max-length 3)) "...")
      text))

(define-helper pluralize (count singular plural)
  (if (= count 1) singular plural))

(define-helper capitalize (str)
  (if (string=? str "")
      str
      (string-append (string-upcase (substring str 0 1))
                     (substring str 1))))
```

### Date Helpers

```racket
(define-helper format-date (timestamp)
  (define date (seconds->date (string->number timestamp)))
  (format "~a/~a/~a" 
          (date-month date) (date-day date) (date-year date)))

(define-helper time-ago (timestamp)
  (define now (current-seconds))
  (define diff (- now (string->number timestamp)))
  (cond
    [(< diff 60) "just now"]
    [(< diff 3600) (format "~a minutes ago" (quotient diff 60))]
    [(< diff 86400) (format "~a hours ago" (quotient diff 3600))]
    [else (format "~a days ago" (quotient diff 86400))]))

(define-helper format-datetime (timestamp)
  (define date (seconds->date (string->number timestamp)))
  (format "~a/~a/~a at ~a:~02d" 
          (date-month date) (date-day date) (date-year date)
          (date-hour date) (date-minute date)))
```

### URL Helpers

```racket
(define-helper user-path (user-id)
  (string-append "/users/" user-id))

(define-helper post-path (user-id post-id)
  (string-append "/users/" user-id "/posts/" post-id))

(define-helper asset-path (filename)
  (string-append "/assets/" filename))
```

### HTML Helpers

```racket
(define-helper link-to (text url)
  `(a ([href ,url]) ,text))

(define-helper image-tag (src alt)
  `(img ([src ,src] [alt ,alt])))

(define-helper form-field (type name value)
  `(input ([type ,type] [name ,name] [value ,value])))
```

## Using Helpers

### In Templates

```racket
(define-template post-page (post)
  `(article
     (h1 ,(hash-ref post 'title))
     (p ,(helper 'truncate (hash-ref post 'content) 200))
     (time ,(helper 'time-ago (hash-ref post 'created-at)))
     (p ,(helper 'link-to "Read more" (helper 'post-path 
                                             (hash-ref post 'user-id)
                                             (hash-ref post 'id))))))
```

### In Route Handlers

```racket
(get "/posts"
  (let ([posts (get-all-posts)])
    (html 
      `(div
         (h1 ,(string-append (number->string (length posts)) " "
                            (helper 'pluralize (length posts) "post" "posts")))
         ,@(map (lambda (post)
                  `(div
                     (h2 ,(hash-ref post 'title))
                     (p ,(helper 'truncate (hash-ref post 'content) 100))))
                posts)))))
```

## Helper Organization

### Grouping Helpers by Category

```racket
; date-helpers.rkt
(define-helper format-date ...)
(define-helper time-ago ...)
(define-helper format-datetime ...)

; text-helpers.rkt  
(define-helper truncate ...)
(define-helper pluralize ...)
(define-helper capitalize ...)

; url-helpers.rkt
(define-helper user-path ...)
(define-helper post-path ...)
(define-helper asset-path ...)
```

### Loading Helper Modules

```racket
; In your main app
(require "helpers/date-helpers.rkt"
         "helpers/text-helpers.rkt"
         "helpers/url-helpers.rkt")
```

## Advanced Filter Patterns

### Conditional Filters

```racket
(before 'all (lambda (req)
  (when (development-mode?)
    (printf "DEBUG: Processing ~a\n" (url->string (request-uri req))))))
```

### Filter Chains

```racket
(before 'all log-request)
(before 'all parse-auth-header)
(before "/api/*" validate-api-key)
(before "/admin/*" require-admin)
```

### Request Modification

```racket
(before 'all (lambda (req)
  ; Add request ID for tracing
  (hash-set! (current-params) 'request-id (generate-uuid))
  
  ; Parse JSON body for API requests
  (when (string-contains? (url->string (request-uri req)) "/api/")
    (define body (read-json-body req))
    (for ([(key value) (in-hash body)])
      (hash-set! (current-params) key value)))))
```

## Performance Considerations

### Filter Performance

```racket
; Cache expensive operations
(define user-cache (make-hash))

(before 'all (lambda (req)
  (define user-id (hash-ref (current-params) 'user-id #f))
  (when user-id
    (define user (hash-ref user-cache user-id
                          (lambda ()
                            (define u (find-user user-id))
                            (hash-set! user-cache user-id u)
                            u)))
    (hash-set! (current-params) 'user user))))
```

### Helper Memoization

```racket
(define format-cache (make-hash))

(define-helper cached-format-date (timestamp)
  (hash-ref format-cache timestamp
            (lambda ()
              (define result (format-date timestamp))
              (hash-set! format-cache timestamp result)
              result)))
```