# Ella Framework Public API

## Core Routing

### HTTP Methods
```racket
(get route-pattern handler)
(post route-pattern handler)
(put route-pattern handler)
(patch route-pattern handler)
(head route-pattern handler)
```

**Route Patterns:**
- String literals: `"/users"`
- Named parameters: `"/users/:id"`
- Splat parameters: `"/files/*"`
- Mixed: `"/users/:id/files/*"`

## Parameters

### Accessing Parameters
```racket
(params)  ; Returns hash of all parameters
(hash-ref (params) 'name)  ; Get specific parameter
(hash-ref (params) 'name "default")  ; With default value
```

**Parameter Sources:**
- URL query strings: `?name=value`
- Named route parameters: `/:id`
- Splat parameters: `/*`
- POST body data

## Responses

### Basic Responses
```racket
"Simple string response"
(html xexpr)  ; HTML response from xexpr
(json-response data)  ; JSON response
```

### Content Types
```racket
(content-type 'json)     ; "application/json"
(content-type 'html)     ; "text/html"
(content-type 'text)     ; "text/plain"
(content-type 'xml)      ; "application/xml"
```

## Templates

### Template Definition
```racket
(define-template name (param1 param2 ...)
  template-body)
```

### Template Usage
```racket
(template 'name arg1 arg2 ...)
```

### Layouts
```racket
(define-layout name (content param1 param2 ...)
  layout-body)

(layout 'name content arg1 arg2 ...)
```

### Scribble Templates
```racket
(scribble-template 
  '(title "Page Title"
    (section "Section Header")
    (para "Paragraph with " (bold "bold") " text")
    (itemlist "Item 1" "Item 2" "Item 3")
    (link "Link Text" "/url")))
```

## Filters

### Before Filters
```racket
(before pattern handler)
(before 'all handler)           ; Run on all requests
(before "/admin/*" handler)     ; Run on specific routes
```

### After Filters
```racket
(after pattern handler)
(after 'all handler)            ; Run on all responses
```

## Helpers

### Helper Definition
```racket
(define-helper name (param1 param2 ...)
  helper-body)
```

### Helper Usage
```racket
(helper 'name arg1 arg2 ...)
```

## Error Handling

### Custom Error Pages
```racket
(define-error-handler 404 handler)
(define-error-handler 500 handler)
(define-error-handler 403 handler)
```

### Error Handler Function
```racket
(error-handler code request . args)
```

## Utility Functions

### Date/Time
```racket
(current-seconds)
(seconds->date timestamp)
(date-year date)
(date-month date) 
(date-day date)
(date-hour date)
(date-minute date)
```

### String Formatting
```racket
(format "template ~a ~a" arg1 arg2)
```

### Request Information
```racket
(current-request)        ; Current request object
(request-method req)     ; HTTP method
(request-uri req)        ; Request URI
(url->string uri)        ; Convert URI to string
```

## Response Construction

### Headers
```racket
(header name value)              ; Create header pair
(response-headers response)      ; Get response headers
(response-output response)       ; Get response output function
```

### Response Types
```racket
(response/output output-function)
(response/output #:headers headers #:code code output-function)
```