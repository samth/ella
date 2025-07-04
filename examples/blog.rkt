#lang ella/main-new

;; Simple Blog Example
;; Demonstrates templates, layouts, and basic CRUD operations

;; Sample data
(define posts 
  (list (hash 'id "1" 'title "First Post" 'content "This is my first blog post!" 'created-at "1751640000")
        (hash 'id "2" 'title "Second Post" 'content "Another great post here." 'created-at "1751643600")))

;; Helpers
(define-helper format-date (timestamp)
  (define date (seconds->date (string->number timestamp)))
  (format "~a/~a/~a at ~a:~02d" 
          (date-month date) (date-day date) (date-year date)
          (date-hour date) (date-minute date)))

(define-helper truncate (text max-length)
  (if (> (string-length text) max-length)
      (string-append (substring text 0 (- max-length 3)) "...")
      text))

;; Layout
(define-layout blog-layout (content title)
  `(html
     (head 
       (title ,title)
       (meta ([charset "utf-8"]))
       (style "
         body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
         header { border-bottom: 1px solid #ccc; padding-bottom: 20px; margin-bottom: 20px; }
         .post { margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
         .meta { color: #666; font-size: 0.9em; }
         nav a { margin-right: 15px; text-decoration: none; color: #0066cc; }
         nav a:hover { text-decoration: underline; }
       "))
     (body
       (header
         (h1 "My Blog")
         (nav
           (a ([href "/"]) "Home")
           (a ([href "/posts"]) "All Posts")
           (a ([href "/about"]) "About")))
       (main ,content))))

;; Templates
(define-template post-list (posts)
  (layout 'blog-layout
          `(div
             (h2 "Recent Posts")
             ,@(map (lambda (post)
                      `(article ([class "post"])
                         (h3 (a ([href ,(string-append "/posts/" (hash-ref post 'id))])
                               ,(hash-ref post 'title)))
                         (div ([class "meta"]) 
                              "Posted on " ,(helper 'format-date (hash-ref post 'created-at)))
                         (p ,(helper 'truncate (hash-ref post 'content) 150))))
                    posts))
          "My Blog"))

(define-template post-detail (post)
  (layout 'blog-layout
          `(article
             (h2 ,(hash-ref post 'title))
             (div ([class "meta"]) 
                  "Posted on " ,(helper 'format-date (hash-ref post 'created-at)))
             (div ,(hash-ref post 'content))
             (p (a ([href "/posts"]) "← Back to all posts")))
          (string-append (hash-ref post 'title) " - My Blog")))

(define-template about-page ()
  (layout 'blog-layout
          `(div
             (h2 "About")
             (p "Welcome to my blog! This is a simple blog built with the Ella framework for Racket.")
             (p "Features demonstrated:")
             (ul
               (li "Template system with layouts")
               (li "Helper functions for date formatting and text truncation") 
               (li "Route parameters")
               (li "Static content serving"))
             (p (a ([href "/"]) "← Back to home")))
          "About - My Blog"))

;; Routes
(get "/" 
  (html (template 'post-list posts)))

(get "/posts" 
  (html (template 'post-list posts)))

(get "/posts/:id"
  (let ([post-id (hash-ref (params) 'id)]
        [post (findf (lambda (p) (string=? (hash-ref p 'id) post-id)) posts)])
    (if post
        (html (template 'post-detail post))
        (error-handler 404 (current-request)))))

(get "/about"
  (html (template 'about-page)))

;; Custom 404 page
(define-error-handler 404 (lambda (req)
  (html (layout 'blog-layout
                `(div
                   (h2 "Page Not Found")
                   (p "Sorry, the page you're looking for doesn't exist.")
                   (p (a ([href "/"]) "← Back to home")))
                "404 - Page Not Found"))))