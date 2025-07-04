#lang racket/base

(require racket/hash
         racket/list
         xml
         web-server/http/xexpr)

(provide define-template
         template
         define-layout
         layout
         html
         scribble-template)

;; Template system
(define template-registry (make-hash))

(define (template name . args)
  (apply (template-function name) args))

(define (template-function name)
  (hash-ref template-registry name
            (λ () (error 'template "Template not found: ~a" name))))

(define-syntax-rule (define-template name (param ...) body ...)
  (hash-set! template-registry 'name (λ (param ...) body ...)))

;; Layout system
(define layout-registry (make-hash))

(define (layout name content . args)
  (apply (layout-function name) content args))

(define (layout-function name)
  (hash-ref layout-registry name
            (λ () (error 'layout "Layout not found: ~a" name))))

(define-syntax-rule (define-layout name (content param ...) body ...)
  (hash-set! layout-registry 'name (λ (content param ...) body ...)))

;; HTML response helper
(define (html xexpr)
  (response/xexpr xexpr))

;; Scribble template support
(define (scribble-template content)
  "Basic Scribble template support - converts simple markup to HTML"
  (cond
    [(list? content)
     (case (first content)
       [(title) `(h1 ,(scribble-template (second content)))]
       [(section) `(h2 ,(scribble-template (second content)))]
       [(para) `(p ,@(map scribble-template (rest content)))]
       [(bold) `(strong ,(scribble-template (second content)))]
       [(italic) `(em ,(scribble-template (second content)))]
       [(itemlist) `(ul ,@(map (λ (item) `(li ,(scribble-template item))) 
                               (rest content)))]
       [(link) `(a ([href ,(scribble-template (third content))]) 
                   ,(scribble-template (second content)))]
       [else (map scribble-template content)])]
    [else content]))