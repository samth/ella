#lang ella/main-new

;; Todo Application Example
;; Demonstrates forms, sessions, and dynamic content

;; Todo data store
(define todos (make-hash))
(define next-todo-id 1)

;; Add some sample todos
(hash-set! todos "1" (hash 'id "1" 'text "Learn Racket" 'completed #f 'created-at (current-seconds)))
(hash-set! todos "2" (hash 'id "2" 'text "Build web app with Ella" 'completed #f 'created-at (current-seconds)))
(set! next-todo-id 3)

;; Helpers
(define-helper format-time (timestamp)
  (define date (seconds->date timestamp))
  (format "~a/~a/~a" (date-month date) (date-day date) (date-year date)))

(define-helper completed-count (todos)
  (length (filter (lambda (todo) (hash-ref todo 'completed)) todos)))

(define-helper pending-count (todos)
  (length (filter (lambda (todo) (not (hash-ref todo 'completed))) todos)))

;; Layout
(define-layout app-layout (content title)
  `(html
     (head 
       (title ,title)
       (meta ([charset "utf-8"]))
       (meta ([name "viewport"] [content "width=device-width, initial-scale=1"]))
       (style "
         body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
                max-width: 600px; margin: 40px auto; padding: 20px; line-height: 1.6; }
         .header { text-align: center; margin-bottom: 40px; }
         .stats { display: flex; justify-content: space-around; margin: 20px 0; 
                  padding: 20px; background: #f5f5f5; border-radius: 8px; }
         .stat { text-align: center; }
         .stat-number { font-size: 24px; font-weight: bold; color: #0066cc; }
         .todo-form { margin: 30px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
         .todo-form input[type=text] { width: 70%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
         .todo-form button { padding: 10px 20px; background: #0066cc; color: white; border: none; 
                            border-radius: 4px; cursor: pointer; margin-left: 10px; }
         .todo-form button:hover { background: #0052a3; }
         .todo-list { list-style: none; padding: 0; }
         .todo-item { display: flex; align-items: center; padding: 15px; margin: 10px 0; 
                      border: 1px solid #eee; border-radius: 8px; background: white; }
         .todo-item.completed { opacity: 0.6; text-decoration: line-through; }
         .todo-item input[type=checkbox] { margin-right: 15px; transform: scale(1.2); }
         .todo-text { flex: 1; }
         .todo-meta { font-size: 0.9em; color: #666; margin-left: 15px; }
         .todo-actions { margin-left: 15px; }
         .delete-btn { background: #dc3545; color: white; border: none; padding: 5px 10px; 
                       border-radius: 4px; cursor: pointer; font-size: 0.8em; }
         .delete-btn:hover { background: #c82333; }
         .filters { margin: 20px 0; text-align: center; }
         .filters a { margin: 0 10px; text-decoration: none; color: #0066cc; padding: 5px 10px; 
                      border-radius: 4px; }
         .filters a:hover, .filters a.active { background: #0066cc; color: white; }
       "))
     (body
       (div ([class "header"])
         (h1 "Todo App")
         (p "Built with Ella Framework"))
       ,content)))

;; Templates
(define-template todo-list (todos filter)
  (define filtered-todos 
    (case filter
      [(completed) (filter (lambda (t) (hash-ref t 'completed)) todos)]
      [(pending) (filter (lambda (t) (not (hash-ref t 'completed))) todos)]
      [else todos]))
  
  (app-layout 
    `(div
       (div ([class "stats"])
         (div ([class "stat"])
           (div ([class "stat-number"]) ,(number->string (length todos)))
           (div "Total"))
         (div ([class "stat"])
           (div ([class "stat-number"]) ,(number->string (helper 'pending-count todos)))
           (div "Pending"))
         (div ([class "stat"])
           (div ([class "stat-number"]) ,(number->string (helper 'completed-count todos)))
           (div "Completed")))
       
       (div ([class "filters"])
         (a ([href "/"] ,@(if (eq? filter 'all) '([class "active"]) '())) "All")
         (a ([href "/pending"] ,@(if (eq? filter 'pending) '([class "active"]) '())) "Pending") 
         (a ([href "/completed"] ,@(if (eq? filter 'completed) '([class "active"]) '())) "Completed"))
       
       (form ([class "todo-form"] [method "post"] [action "/todos"])
         (input ([type "text"] [name "text"] [placeholder "What needs to be done?"] [required ""]))
         (button ([type "submit"]) "Add Todo"))
       
       (ul ([class "todo-list"])
         ,@(map (lambda (todo)
                  `(li ([class ,(string-append "todo-item" 
                                               (if (hash-ref todo 'completed) " completed" ""))])
                     (form ([method "post"] [action ,(string-append "/todos/" (hash-ref todo 'id) "/toggle")]
                            [style "display: inline; margin-right: 15px;"])
                       (input ([type "checkbox"] 
                               [onchange "this.form.submit()"]
                               ,@(if (hash-ref todo 'completed) '([checked ""]) '()))))
                     (span ([class "todo-text"]) ,(hash-ref todo 'text))
                     (span ([class "todo-meta"]) ,(helper 'format-time (hash-ref todo 'created-at)))
                     (div ([class "todo-actions"])
                       (form ([method "post"] [action ,(string-append "/todos/" (hash-ref todo 'id) "/delete")]
                              [style "display: inline;"])
                         (button ([type "submit"] [class "delete-btn"] 
                                 [onclick "return confirm('Delete this todo?')"])
                                "Delete")))))
                filtered-todos)))
    "Todo App"))

;; Routes
(get "/" 
  (html (template 'todo-list (hash-values todos) 'all)))

(get "/pending"
  (html (template 'todo-list (hash-values todos) 'pending)))

(get "/completed" 
  (html (template 'todo-list (hash-values todos) 'completed)))

;; Create new todo
(post "/todos"
  (let ([text (hash-ref (params) 'text "")])
    (unless (string=? text "")
      (define todo-id (number->string next-todo-id))
      (define new-todo (hash 'id todo-id
                            'text text
                            'completed #f
                            'created-at (current-seconds)))
      (hash-set! todos todo-id new-todo)
      (set! next-todo-id (+ next-todo-id 1)))
    ; Redirect back to main page
    (response/output
      #:code 302
      #:headers (list (header #"Location" #"/"))
      (lambda (out) (display "" out)))))

;; Toggle todo completion
(post "/todos/:id/toggle"
  (let ([todo-id (hash-ref (params) 'id)]
        [todo (hash-ref todos (hash-ref (params) 'id) #f)])
    (when todo
      (hash-set! todos todo-id 
                 (hash-set todo 'completed (not (hash-ref todo 'completed)))))
    ; Redirect back
    (response/output
      #:code 302  
      #:headers (list (header #"Location" #"/"))
      (lambda (out) (display "" out)))))

;; Delete todo
(post "/todos/:id/delete"
  (let ([todo-id (hash-ref (params) 'id)])
    (hash-remove! todos todo-id)
    ; Redirect back
    (response/output
      #:code 302
      #:headers (list (header #"Location" #"/"))
      (lambda (out) (display "" out)))))

;; API endpoints for AJAX (bonus)
(get "/api/todos"
  (json-response (hash-values todos)))

(post "/api/todos"
  (let ([text (hash-ref (params) 'text "")])
    (if (string=? text "")
        (json-response (hash 'error "Text is required") #:code 400)
        (begin
          (define todo-id (number->string next-todo-id))
          (define new-todo (hash 'id todo-id
                                'text text
                                'completed #f
                                'created-at (current-seconds)))
          (hash-set! todos todo-id new-todo)
          (set! next-todo-id (+ next-todo-id 1))
          (json-response new-todo)))))