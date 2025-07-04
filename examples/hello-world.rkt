#lang ella/main-new

;; Hello World Example
;; The simplest possible Ella application

(get "/" "Hello, World!")

(get "/hello/:name" 
  (string-append "Hello, " (hash-ref (params) 'name) "!"))