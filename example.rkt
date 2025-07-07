#lang ella
(require (file "main.rkt"))

;; Define helper functions
(define-helper format-date (timestamp)
  (define date (seconds->date (string->number timestamp)))
  (format "~a/~a/~a at ~a:~a" 
          (date-month date) (date-day date) (date-year date)
          (date-hour date) (date-minute date)))

(define-helper pluralize (count singular plural)
  (if (= count 1) singular plural))

(define-helper truncate (str max-len)
  (if (> (string-length str) max-len)
      (string-append (substring str 0 (- max-len 3)) "...")
      str))

;; Before filter to log all requests
(before 'all (lambda (req)
               (printf "REQUEST: ~a ~a\n" 
                       (request-method req)
                       (url->string (request-uri req)))))

;; Before filter to add timestamp to params for specific routes
(before "/user/:id" (lambda (req)
                      (hash-set! (current-params) 'timestamp 
                                 (number->string (current-seconds)))))

;; After filter to add custom header
(after 'all (lambda (req resp)
              (response/output 
               #:headers (cons (header #"X-Powered-By" #"Ella-Framework")
                              (response-headers resp))
               (response-output resp))))

;; Custom error pages
(define-error-handler 404 (lambda (req)
                            (html (layout 'main-layout
                                          `(div
                                             (h2 "Page Not Found")
                                             (p "Sorry, the page you're looking for doesn't exist.")
                                             (p (a ([href "/"]) "Go Home")))
                                          "404 - Page Not Found"))))

(define-error-handler 500 (lambda (req error-msg)
                            (html (layout 'main-layout
                                          `(div
                                             (h2 "Internal Server Error")
                                             (p "Something went wrong on our end.")
                                             (p "Error details: " ,(format "~a" error-msg))
                                             (p (a ([href "/"]) "Go Home")))
                                          "500 - Server Error"))))

(define-layout main-layout (content title)
  `(html
     (head
       (title ,title)
       (meta ([charset "utf-8"]))
       (style "body { font-family: Arial, sans-serif; margin: 40px; }"))
     (body
       (header
         (h1 "My Web App")
         (nav (a ([href "/"]) "Home") " | " (a ([href "/about"]) "About")))
       (main ,content)
       (footer (p "© 2025 My Web App")))))

(define-template user-page (name id)
  (layout 'main-layout
          `(div
             (h2 ,(string-append "Welcome, " (helper 'truncate name 20) "!"))
             (p ,(string-append "Your ID is: " id))
             (p ,(string-append "Request timestamp: " 
                               (helper 'format-date (hash-ref (params) 'timestamp "0"))))
             (p ,(string-append (helper 'pluralize 1 "You have" "You have")
                               " "
                               (helper 'pluralize 1 "notification" "notifications")))
             (p (a ([href "/api/user/" ,id]) "View JSON API")))
          (string-append "User: " name)))

(get /dont-mean-a-thing (response "If it ain't got that swing!"))

(get "/hello/:name" (string-append "Hello, " (hash-ref (params) 'name)))

(get "/say/*/to/*" (string-append "Say " (first (hash-ref (params) 'splat)) " to " (second (hash-ref (params) 'splat))))

(get "/greet" (response (string-append "Greetings, " (hash-ref (params) 'name "stranger") "!")))

(get "/api/user/:id" (response/json (hash 'id (hash-ref (params) 'id) 'name "test-user")))

(get "/user/:id" (html (template 'user-page "John Doe" (hash-ref (params) 'id))))

(get "/error-test" (error "This is a test error!"))

(get "/scribble-demo" 
     (html 
      (layout 'main-layout
              `(div
                ,(scribble-template '(title "Scribble-style Demo"))
                ,(scribble-template '(section "Features"))
                ,(scribble-template '(para "This demonstrates " (bold "basic") " Scribble-like markup:"))
                ,(scribble-template '(itemlist "Simple text formatting"
                                               "Lists and links"  
                                               "Nested structures"))
                ,(scribble-template '(para "Visit " (link "our homepage" "/") " for more.")))
              "Scribble Demo")))
