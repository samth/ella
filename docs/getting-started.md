# Getting Started with Ella

## Installation

Install Ella from the Racket package catalog:

```bash
raco pkg install ella
```

## Your First App

Create a new file `hello.rkt`:

```racket
#lang ella

(get "/" "Hello, World!")
```

Run your app:

```bash
racket hello.rkt
```

Visit `http://localhost:8080` to see your app!

## Basic Routing

### Simple Routes

```racket
(get "/users" "List of users")
(post "/users" "Create a user")
(put "/users/:id" "Update a user")
```

### Named Parameters

```racket
(get "/users/:id" 
  (string-append "User ID: " (hash-ref (params) 'id)))

(get "/users/:id/posts/:post-id"
  (string-append "User " (hash-ref (params) 'id) 
                 " post " (hash-ref (params) 'post-id)))
```

### Splat Parameters

```racket
(get "/files/*"
  (string-append "File path: " (hash-ref (params) 'splat)))

(get "/say/*/to/*"
  (let ([splats (hash-ref (params) 'splat)])
    (string-append "Say " (first splats) " to " (second splats))))
```

### Query Parameters

Ella automatically parses query parameters:

```racket
(get "/search"
  (string-append "Query: " (hash-ref (params) 'q "none")))
```

Visit `/search?q=racket` to see it in action.

## Responses

### String Responses

```racket
(get "/" "Simple string response")
```

### JSON Responses

```racket
(get "/api/users" 
  (json-response (hash 'users '("Alice" "Bob"))))
```

### HTML Responses

```racket
(get "/" 
  (html '(html
           (head (title "My App"))
           (body (h1 "Welcome!")))))
```

## Templates

### Defining Templates

```racket
(define-template user-page (name email)
  `(html
     (head (title ,(string-append "User: " name)))
     (body
       (h1 ,(string-append "Welcome, " name))
       (p ,(string-append "Email: " email)))))

(get "/user/:name"
  (html (template 'user-page 
                  (hash-ref (params) 'name)
                  "user@example.com")))
```

### Layouts

```racket
(define-layout main-layout (content title)
  `(html
     (head (title ,title))
     (body
       (header (h1 "My Site"))
       (main ,content)
       (footer (p "© 2025")))))

(define-template home-page ()
  (layout 'main-layout
          '(div (h2 "Welcome") (p "Home page content"))
          "Home - My Site"))

(get "/" (html (template 'home-page)))
```

## Error Handling

### Custom 404 Pages

```racket
(define-error-handler 404 (lambda (req)
  (html '(html
           (head (title "Page Not Found"))
           (body (h1 "404 - Page Not Found"))))))
```

### Custom 500 Pages

```racket
(define-error-handler 500 (lambda (req error-msg)
  (html `(html
           (head (title "Server Error"))
           (body 
             (h1 "500 - Server Error")
             (p ,(format "Error: ~a" error-msg)))))))
```

## What's Next?

- Learn about [Routing](routing.md) in depth
- Explore [Templates and Layouts](templates.md)
- Discover [Filters and Helpers](filters-helpers.md)
- Check out the [API Reference](../API.md)