# Routing Guide

## HTTP Methods

Ella supports all standard HTTP methods:

```racket
(get "/users" "GET request")
(post "/users" "POST request")  
(put "/users/:id" "PUT request")
(patch "/users/:id" "PATCH request")
(head "/users" "HEAD request")
```

## Route Patterns

### Static Routes

```racket
(get "/" "Home page")
(get "/about" "About page")
(get "/contact" "Contact page")
```

### Named Parameters

Named parameters are prefixed with `:` and captured in the `params` hash:

```racket
(get "/users/:id" 
  (hash-ref (params) 'id))

(get "/users/:user-id/posts/:post-id"
  (string-append "User: " (hash-ref (params) 'user-id)
                 " Post: " (hash-ref (params) 'post-id)))
```

### Splat Parameters

Splat parameters use `*` and capture path segments:

```racket
; Single splat - captures one segment
(get "/files/*" 
  (hash-ref (params) 'splat))

; Multiple splats - returns list
(get "/say/*/to/*"
  (let ([splats (hash-ref (params) 'splat)])
    (string-append (first splats) " " (second splats))))
```

### Mixed Parameters

You can combine named and splat parameters:

```racket
(get "/users/:id/files/*"
  (string-append "User " (hash-ref (params) 'id)
                 " file " (hash-ref (params) 'splat)))
```

## Parameter Access

### The params Function

All parameters (URL, query, and body) are accessible via `(params)`:

```racket
(get "/search"
  (let ([query (hash-ref (params) 'q "")]
        [page (hash-ref (params) 'page "1")])
    (string-append "Searching for: " query " (page " page ")")))
```

### Parameter Types

- **Named parameters**: Symbols (`'id`, `'name`)
- **Splat parameters**: Symbol `'splat`
- **Query parameters**: Symbols based on query keys
- **Form parameters**: Symbols based on form field names

### Default Values

Use `hash-ref` with a default value for optional parameters:

```racket
(get "/users"
  (let ([limit (hash-ref (params) 'limit "10")]
        [offset (hash-ref (params) 'offset "0")])
    (string-append "Showing " limit " users starting at " offset)))
```

## Route Handlers

### Simple Handlers

```racket
(get "/" "Simple string response")
```

### Function Handlers

```racket
(get "/time" 
  (lambda (req)
    (number->string (current-seconds))))
```

### Complex Handlers

```racket
(get "/users/:id"
  (lambda (req)
    (define user-id (hash-ref (params) 'id))
    (define user (find-user user-id))
    (if user
        (json-response user)
        (error-handler 404 req))))
```

## Route Precedence

Routes are matched in the order they are defined:

```racket
(get "/users/new" "New user form")     ; More specific
(get "/users/:id" "Show user")         ; Less specific
```

Always define more specific routes before general ones.

## Query Parameters

Query parameters are automatically parsed:

```racket
; GET /search?q=racket&category=web
(get "/search"
  (let ([query (hash-ref (params) 'q)]
        [category (hash-ref (params) 'category)])
    (string-append "Searching " category " for: " query)))
```

## Form Parameters

POST form data is automatically parsed:

```racket
(post "/users"
  (let ([name (hash-ref (params) 'name)]
        [email (hash-ref (params) 'email)])
    (create-user name email)
    "User created!"))
```

## Advanced Routing

### Conditional Routing

Use Racket's control structures for complex routing logic:

```racket
(get "/admin/*"
  (if (authenticated?)
      (serve-admin-page)
      (redirect-to-login)))
```

### Route Helpers

Define helper functions for common route patterns:

```racket
(define (authenticated-route handler)
  (lambda (req)
    (if (authenticated?)
        (handler req)
        (error-handler 401 req))))

(get "/admin/users" 
  (authenticated-route 
    (lambda (req) "Admin users page")))
```