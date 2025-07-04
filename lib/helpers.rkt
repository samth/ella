#lang racket/base

(require racket/hash)

(provide define-helper
         helper
         helpers)

;; Helper system
(define helper-registry (make-hash))

(define-syntax-rule (define-helper name (param ...) body ...)
  (hash-set! helper-registry 'name (λ (param ...) body ...)))

(define (helper name . args)
  (apply (helper-function name) args))

(define (helper-function name)
  (hash-ref helper-registry name
            (λ () (error 'helper "Helper not found: ~a" name))))

;; Create a helpers namespace that contains all helpers
(define (helpers)
  (define ns (make-hash))
  (for ([(name func) (in-hash helper-registry)])
    (hash-set! ns name func))
  ns)