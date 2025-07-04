#lang ella/main-new

;; RESTful API Server Example
;; Demonstrates JSON responses, error handling, and API patterns

;; Sample data store
(define users (make-hash))
(hash-set! users "1" (hash 'id "1" 'name "Alice" 'email "alice@example.com" 'created-at (current-seconds)))
(hash-set! users "2" (hash 'id "2" 'name "Bob" 'email "bob@example.com" 'created-at (current-seconds)))

(define next-user-id 3)

;; Helper functions
(define-helper api-response (data)
  (json-response (hash 'status "success" 'data data)))

(define-helper api-error (message code)
  (json-response (hash 'status "error" 'message message) #:code code))

;; Before filters
(before "/api/*" (lambda (req)
  (printf "API Request: ~a ~a\n" 
          (request-method req)
          (url->string (request-uri req)))))

;; After filters - Add CORS headers
(after "/api/*" (lambda (req resp)
  (response/output 
    #:headers (append (list (header #"Access-Control-Allow-Origin" #"*")
                           (header #"Access-Control-Allow-Methods" #"GET,POST,PUT,DELETE")
                           (header #"Content-Type" #"application/json"))
                     (response-headers resp))
    (response-output resp))))

;; API Routes

;; GET /api/users - List all users
(get "/api/users"
  (helper 'api-response (hash-values users)))

;; GET /api/users/:id - Get specific user
(get "/api/users/:id"
  (let ([user-id (hash-ref (params) 'id)]
        [user (hash-ref users user-id #f)])
    (if user
        (helper 'api-response user)
        (helper 'api-error "User not found" 404))))

;; POST /api/users - Create new user
(post "/api/users"
  (let ([name (hash-ref (params) 'name #f)]
        [email (hash-ref (params) 'email #f)])
    (cond
      [(not name) (helper 'api-error "Name is required" 400)]
      [(not email) (helper 'api-error "Email is required" 400)]
      [else
       (define user-id (number->string next-user-id))
       (define new-user (hash 'id user-id 
                             'name name 
                             'email email
                             'created-at (current-seconds)))
       (hash-set! users user-id new-user)
       (set! next-user-id (+ next-user-id 1))
       (helper 'api-response new-user)])))

;; PUT /api/users/:id - Update user
(put "/api/users/:id"
  (let ([user-id (hash-ref (params) 'id)]
        [user (hash-ref users user-id #f)])
    (if user
        (let ([name (hash-ref (params) 'name (hash-ref user 'name))]
              [email (hash-ref (params) 'email (hash-ref user 'email))])
          (define updated-user (hash-set* user 'name name 'email email))
          (hash-set! users user-id updated-user)
          (helper 'api-response updated-user))
        (helper 'api-error "User not found" 404))))

;; DELETE /api/users/:id - Delete user  
;; Note: Using patch for demo since DELETE might not work in all browsers
(patch "/api/users/:id/delete"
  (let ([user-id (hash-ref (params) 'id)]
        [user (hash-ref users user-id #f)])
    (if user
        (begin
          (hash-remove! users user-id)
          (helper 'api-response (hash 'message "User deleted")))
        (helper 'api-error "User not found" 404))))

;; API Documentation endpoint
(get "/api"
  (json-response 
    (hash 'name "Users API"
          'version "1.0"
          'endpoints 
          (list
            (hash 'method "GET" 'path "/api/users" 'description "List all users")
            (hash 'method "GET" 'path "/api/users/:id" 'description "Get user by ID")
            (hash 'method "POST" 'path "/api/users" 'description "Create new user")
            (hash 'method "PUT" 'path "/api/users/:id" 'description "Update user")
            (hash 'method "DELETE" 'path "/api/users/:id" 'description "Delete user")))))

;; Health check endpoint
(get "/api/health"
  (json-response (hash 'status "healthy" 'timestamp (current-seconds))))

;; Root route with API info
(get "/"
  (html `(html
           (head (title "API Server"))
           (body
             (h1 "Users API Server")
             (p "This is a RESTful API server built with Ella framework.")
             (h2 "Available Endpoints:")
             (ul
               (li (strong "GET /api") " - API documentation")
               (li (strong "GET /api/health") " - Health check")
               (li (strong "GET /api/users") " - List all users")
               (li (strong "GET /api/users/:id") " - Get user by ID")
               (li (strong "POST /api/users") " - Create new user")
               (li (strong "PUT /api/users/:id") " - Update user")
               (li (strong "DELETE /api/users/:id") " - Delete user"))
             (h2 "Example Usage:")
             (pre "curl http://localhost:8080/api/users")
             (pre "curl -X POST -d \"name=John&email=john@example.com\" http://localhost:8080/api/users")))))

;; Custom error handlers
(define-error-handler 404 (lambda (req)
  (json-response (hash 'status "error" 'message "Endpoint not found") #:code 404)))

(define-error-handler 500 (lambda (req error-msg)
  (json-response (hash 'status "error" 'message "Internal server error") #:code 500)))