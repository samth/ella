#lang info

(define collection "ella")
(define deps '("base"
               "web-server-lib"
               "net-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/ella.scrbl" ())))
(define pkg-desc "A lightweight Sinatra-inspired web framework for Racket")
(define version "1.0")
(define pkg-authors '("Ella Framework Team"))
