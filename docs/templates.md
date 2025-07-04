# Templates and Layouts

## Template System

Ella provides a flexible template system using Racket's native S-expressions (xexprs) and optional Scribble-style markup.

## Defining Templates

### Basic Templates

```racket
(define-template user-page (name email)
  `(html
     (head (title ,(string-append "User: " name)))
     (body
       (h1 ,(string-append "Welcome, " name))
       (p ,(string-append "Email: " email))
       (a ([href "/logout"]) "Logout"))))
```

### Using Templates

```racket
(get "/users/:id"
  (html (template 'user-page 
                  (hash-ref (params) 'id)
                  "user@example.com")))
```

## Layouts

Layouts provide a way to share common page structure across templates.

### Defining Layouts

```racket
(define-layout main-layout (content title)
  `(html
     (head 
       (title ,title)
       (meta ([charset "utf-8"]))
       (link ([rel "stylesheet"] [href "/style.css"])))
     (body
       (header
         (nav
           (a ([href "/"]) "Home")
           (a ([href "/about"]) "About")))
       (main ,content)
       (footer
         (p "© 2025 My Website")))))
```

### Using Layouts

```racket
(define-template home-page ()
  (layout 'main-layout
          `(div
             (h1 "Welcome to My Site")
             (p "This is the home page content"))
          "Home - My Site"))

(get "/" (html (template 'home-page)))
```

## Scribble Templates

Ella supports Scribble-style markup for more readable templates:

### Scribble Syntax

```racket
(get "/docs"
  (html 
    (scribble-template
      '(title "Documentation"
        (section "Getting Started")
        (para "Welcome to the documentation. Here you'll find:")
        (itemlist 
          "Installation instructions"
          "Basic usage examples" 
          "Advanced features")
        (section "Examples")
        (para "Check out these " (link "examples" "/examples") ".")))))
```

### Scribble Elements

- `(title "text")` → `<h1>text</h1>`
- `(section "text")` → `<h2>text</h2>`
- `(para "text")` → `<p>text</p>`
- `(bold "text")` → `<strong>text</strong>`
- `(italic "text")` → `<em>text</em>`
- `(link "text" "url")` → `<a href="url">text</a>`
- `(itemlist "item1" "item2")` → `<ul><li>item1</li><li>item2</li></ul>`

## Template Helpers

Use helpers within templates for common formatting tasks:

### Date Formatting Helper

```racket
(define-helper format-timestamp (ts)
  (define date (seconds->date (string->number ts)))
  (format "~a/~a/~a at ~a:~a" 
          (date-month date) (date-day date) (date-year date)
          (date-hour date) (date-minute date)))

(define-template post-page (title content timestamp)
  `(article
     (h1 ,title)
     (time ,(helper 'format-timestamp timestamp))
     (div ,content)))
```

### Text Formatting Helpers

```racket
(define-helper truncate (text max-length)
  (if (> (string-length text) max-length)
      (string-append (substring text 0 (- max-length 3)) "...")
      text))

(define-helper pluralize (count singular plural)
  (if (= count 1) singular plural))

(define-template comment-list (comments)
  `(div
     (h3 ,(string-append (number->string (length comments)) " "
                        (helper 'pluralize (length comments) "comment" "comments")))
     ,@(map (lambda (comment)
              `(div 
                 (p ,(helper 'truncate comment 100))))
            comments)))
```

## Conditional Templates

### Conditional Content

```racket
(define-template user-profile (user logged-in?)
  `(div
     (h1 ,(hash-ref user 'name))
     (p ,(hash-ref user 'bio))
     ,@(if logged-in?
           `((a ([href "/edit-profile"]) "Edit Profile"))
           '())))
```

### Template Partials

```racket
(define-template navigation (current-user)
  `(nav
     (a ([href "/"]) "Home")
     (a ([href "/posts"]) "Posts")
     ,@(if current-user
           `((a ([href "/dashboard"]) "Dashboard")
             (a ([href "/logout"]) "Logout"))
           `((a ([href "/login"]) "Login")
             (a ([href "/signup"]) "Sign Up")))))

(define-layout app-layout (content title user)
  `(html
     (head (title ,title))
     (body
       ,(template 'navigation user)
       (main ,content))))
```

## Template Organization

### File Structure

```
your-app/
├── templates/
│   ├── layouts/
│   │   ├── main.rkt
│   │   └── admin.rkt
│   ├── pages/
│   │   ├── home.rkt
│   │   ├── about.rkt
│   │   └── contact.rkt
│   └── partials/
│       ├── navigation.rkt
│       └── footer.rkt
├── helpers/
│   ├── date.rkt
│   └── text.rkt
└── app.rkt
```

### Loading Templates

```racket
; In your main app file
(require "templates/layouts/main.rkt"
         "templates/pages/home.rkt"
         "helpers/date.rkt")
```

## Advanced Features

### Template Inheritance

```racket
(define-layout base-layout (content title stylesheets scripts)
  `(html
     (head
       (title ,title)
       ,@stylesheets)
     (body
       ,content
       ,@scripts)))

(define-layout admin-layout (content title)
  (template 'base-layout content title
            '((link ([rel "stylesheet"] [href "/admin.css"])))
            '((script ([src "/admin.js"])))))
```

### Template Caching

For production applications, consider caching compiled templates:

```racket
(define template-cache (make-hash))

(define (cached-template name . args)
  (define cache-key (cons name args))
  (hash-ref template-cache cache-key
            (lambda ()
              (define result (apply template name args))
              (hash-set! template-cache cache-key result)
              result)))
```