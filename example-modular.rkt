#lang ella/main-new

;; Define helper functions
(define-helper format-date (timestamp)
  (define date (seconds->date (string->number timestamp)))
  (format "~a/~a/~a at ~a:~a" 
          (date-month date) (date-day date) (date-year date)
          (date-hour date) (date-minute date)))

;; Before filter to log all requests
(before 'all (lambda (req)
               (printf "REQUEST: ~a ~a\n" 
                       (request-method req)
                       (url->string (request-uri req)))))

;; Custom error pages
(define-error-handler 404 (lambda (req)
                            (html `(html
                                     (head (title "404 - Not Found"))
                                     (body 
                                       (h1 "Page Not Found")
                                       (p "The page you're looking for doesn't exist."))))))

(define-layout main-layout (content title)
  `(html
     (head
       (title ,title)
       (meta ([charset "utf-8"])))
     (body
       (header (h1 "Ella Framework Demo"))
       (main ,content)
       (footer (p "Powered by Ella")))))

(get "/test" (html (layout 'main-layout
                           `(div
                              (h2 "Modular Test")
                              (p "This uses the refactored modular codebase!")
                              (p ,(helper 'format-date (number->string (current-seconds)))))
                           "Modular Test")))