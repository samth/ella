#lang ella

(get /dont-mean-a-thing "If it ain't got that swing!")

(get "/hello/:name" (string-append "Hello, " (hash-ref (params) 'name)))
