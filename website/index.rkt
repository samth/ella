#lang ella/main-new

;; Ella Framework Website
;; Modern, attractive website showcasing the framework

;; Helper functions
(define-helper highlight-code (code lang)
  `(pre ([class ,(string-append "language-" lang)])
     (code ([class ,(string-append "language-" lang)]) ,code)))

(define-helper feature-card (icon title description)
  `(div ([class "feature-card"])
     (div ([class "feature-icon"]) ,icon)
     (h3 ,title)
     (p ,description)))

;; Main layout
(define-layout site-layout (content title description)
  `(html ([lang "en"])
     (head
       (meta ([charset "utf-8"]))
       (meta ([name "viewport"] [content "width=device-width, initial-scale=1"]))
       (meta ([name "description"] [content ,description]))
       (title ,title)
       
       ;; Modern CSS with CSS Grid and Flexbox
       (style "
         :root {
           --primary: #0066cc;
           --primary-dark: #0052a3;
           --secondary: #f8f9fa;
           --text: #2c3e50;
           --text-light: #6c757d;
           --border: #e9ecef;
           --success: #28a745;
           --warning: #ffc107;
           --gradient: linear-gradient(135deg, var(--primary) 0%, #0084ff 100%);
         }
         
         * { margin: 0; padding: 0; box-sizing: border-box; }
         
         body {
           font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
           line-height: 1.6;
           color: var(--text);
           overflow-x: hidden;
         }
         
         .container {
           max-width: 1200px;
           margin: 0 auto;
           padding: 0 2rem;
         }
         
         /* Header */
         .header {
           background: white;
           border-bottom: 1px solid var(--border);
           position: fixed;
           top: 0;
           left: 0;
           right: 0;
           z-index: 1000;
           backdrop-filter: blur(10px);
         }
         
         .nav {
           display: flex;
           align-items: center;
           justify-content: space-between;
           height: 4rem;
         }
         
         .logo {
           font-size: 1.5rem;
           font-weight: bold;
           color: var(--primary);
           text-decoration: none;
         }
         
         .nav-links {
           display: flex;
           gap: 2rem;
           list-style: none;
         }
         
         .nav-links a {
           text-decoration: none;
           color: var(--text);
           font-weight: 500;
           transition: color 0.3s;
         }
         
         .nav-links a:hover {
           color: var(--primary);
         }
         
         /* Hero Section */
         .hero {
           background: var(--gradient);
           color: white;
           padding: 8rem 0 6rem;
           margin-top: 4rem;
           text-align: center;
           position: relative;
           overflow: hidden;
         }
         
         .hero::before {
           content: '';
           position: absolute;
           top: 0;
           left: 0;
           right: 0;
           bottom: 0;
           background: url('data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"2\" fill=\"%23ffffff\" opacity=\"0.1\"/></svg>') repeat;
           background-size: 50px 50px;
         }
         
         .hero-content {
           position: relative;
           z-index: 1;
         }
         
         .hero h1 {
           font-size: 3.5rem;
           font-weight: 700;
           margin-bottom: 1rem;
           background: linear-gradient(45deg, #fff, #e3f2fd);
           -webkit-background-clip: text;
           -webkit-text-fill-color: transparent;
           background-clip: text;
         }
         
         .hero .subtitle {
           font-size: 1.25rem;
           margin-bottom: 2rem;
           opacity: 0.9;
         }
         
         .cta-buttons {
           display: flex;
           gap: 1rem;
           justify-content: center;
           margin-bottom: 3rem;
         }
         
         .btn {
           display: inline-block;
           padding: 0.75rem 2rem;
           border-radius: 0.5rem;
           text-decoration: none;
           font-weight: 600;
           transition: all 0.3s;
           border: 2px solid transparent;
         }
         
         .btn-primary {
           background: white;
           color: var(--primary);
         }
         
         .btn-primary:hover {
           transform: translateY(-2px);
           box-shadow: 0 8px 25px rgba(0,0,0,0.15);
         }
         
         .btn-secondary {
           background: transparent;
           color: white;
           border-color: white;
         }
         
         .btn-secondary:hover {
           background: white;
           color: var(--primary);
         }
         
         /* Code Preview */
         .code-preview {
           background: rgba(0,0,0,0.1);
           border-radius: 0.5rem;
           padding: 1.5rem;
           margin: 2rem auto 0;
           max-width: 600px;
           backdrop-filter: blur(10px);
         }
         
         .code-preview pre {
           background: none;
           color: white;
           font-family: 'Fira Code', Monaco, 'Cascadia Code', monospace;
           font-size: 0.9rem;
           line-height: 1.5;
           overflow-x: auto;
         }
         
         /* Features Section */
         .features {
           padding: 6rem 0;
           background: var(--secondary);
         }
         
         .features-grid {
           display: grid;
           grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
           gap: 2rem;
           margin-top: 3rem;
         }
         
         .feature-card {
           background: white;
           padding: 2rem;
           border-radius: 1rem;
           border: 1px solid var(--border);
           text-align: center;
           transition: transform 0.3s, box-shadow 0.3s;
         }
         
         .feature-card:hover {
           transform: translateY(-5px);
           box-shadow: 0 10px 30px rgba(0,0,0,0.1);
         }
         
         .feature-icon {
           font-size: 3rem;
           margin-bottom: 1rem;
         }
         
         .feature-card h3 {
           margin-bottom: 1rem;
           color: var(--primary);
         }
         
         /* Examples Section */
         .examples {
           padding: 6rem 0;
         }
         
         .example-tabs {
           display: flex;
           gap: 1rem;
           margin-bottom: 2rem;
           border-bottom: 1px solid var(--border);
         }
         
         .tab-button {
           padding: 0.75rem 1.5rem;
           background: none;
           border: none;
           cursor: pointer;
           border-bottom: 3px solid transparent;
           font-weight: 600;
           color: var(--text-light);
           transition: all 0.3s;
         }
         
         .tab-button.active {
           color: var(--primary);
           border-bottom-color: var(--primary);
         }
         
         .code-block {
           background: #f8f9fa;
           border: 1px solid var(--border);
           border-radius: 0.5rem;
           padding: 1.5rem;
           overflow-x: auto;
         }
         
         .code-block pre {
           background: none;
           margin: 0;
           font-family: 'Fira Code', Monaco, monospace;
         }
         
         /* Stats Section */
         .stats {
           background: var(--gradient);
           color: white;
           padding: 4rem 0;
           text-align: center;
         }
         
         .stats-grid {
           display: grid;
           grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
           gap: 2rem;
           margin-top: 2rem;
         }
         
         .stat-item h3 {
           font-size: 2.5rem;
           font-weight: bold;
           margin-bottom: 0.5rem;
         }
         
         /* Footer */
         .footer {
           background: var(--text);
           color: white;
           padding: 3rem 0 2rem;
         }
         
         .footer-content {
           display: grid;
           grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
           gap: 2rem;
         }
         
         .footer h4 {
           margin-bottom: 1rem;
           color: var(--primary);
         }
         
         .footer a {
           color: #ccc;
           text-decoration: none;
           transition: color 0.3s;
         }
         
         .footer a:hover {
           color: white;
         }
         
         /* Responsive */
         @media (max-width: 768px) {
           .hero h1 { font-size: 2.5rem; }
           .cta-buttons { flex-direction: column; align-items: center; }
           .nav-links { display: none; }
           .container { padding: 0 1rem; }
         }
       "))
     (body
       ,content)))

;; Templates
(define-template home-page ()
  (site-layout
    `(div
       ;; Header
       (header ([class "header"])
         (div ([class "container"])
           (nav ([class "nav"])
             (a ([href "/"] [class "logo"]) "Ella")
             (ul ([class "nav-links"])
               (li (a ([href "#features"]) "Features"))
               (li (a ([href "#examples"]) "Examples"))
               (li (a ([href "/docs"]) "Docs"))
               (li (a ([href "/examples"]) "Examples"))
               (li (a ([href "https://github.com/ella-framework/ella"]) "GitHub"))))))
       
       ;; Hero Section
       (section ([class "hero"])
         (div ([class "container"])
           (div ([class "hero-content"])
             (h1 "Ella Framework")
             (p ([class "subtitle"]) 
               "A lightweight, Sinatra-inspired web framework for Racket")
             (div ([class "cta-buttons"])
               (a ([href "/docs/getting-started"] [class "btn btn-primary"]) "Get Started")
               (a ([href "#examples"] [class "btn btn-secondary"]) "View Examples"))
             
             (div ([class "code-preview"])
               ,(helper 'highlight-code 
                       "#lang ella

(get \"/hello/:name\" 
  (string-append \"Hello, \" (hash-ref (params) 'name) \"!\"))

(get \"/api/users\" 
  (json-response (hash 'users '(\"Alice\" \"Bob\"))))"
                       "racket")))))
       
       ;; Features Section  
       (section ([class "features"] [id "features"])
         (div ([class "container"])
           (h2 ([style "text-align: center; margin-bottom: 1rem;"]) "Why Choose Ella?")
           (p ([style "text-align: center; color: var(--text-light); margin-bottom: 3rem;"])
             "Built for developers who want simplicity without sacrificing power")
           
           (div ([class "features-grid"])
             ,(helper 'feature-card "🚀" "Simple Routing" 
                     "Express-style routing with named parameters, splat parameters, and intuitive pattern matching")
             ,(helper 'feature-card "🎨" "Flexible Templates"
                     "Built-in support for Racket Xexprs and Scribble-style markup with powerful layout system")
             ,(helper 'feature-card "🔧" "Powerful Filters"
                     "Before and after filters for authentication, logging, CORS, and request/response modification")
             ,(helper 'feature-card "🧰" "Rich Helpers"
                     "Reusable helper functions for date formatting, text processing, and common web tasks")
             ,(helper 'feature-card "📝" "JSON First"
                     "Built-in JSON support with automatic serialization and proper content-type headers")
             ,(helper 'feature-card "⚡" "Production Ready"
                     "Custom error pages, exception handling, and modular architecture for scalability"))))
       
       ;; Examples Section
       (section ([class "examples"] [id "examples"])
         (div ([class "container"])
           (h2 ([style "text-align: center; margin-bottom: 3rem;"]) "See Ella in Action")
           
           (div ([class "example-tabs"])
             (button ([class "tab-button active"]) "Hello World")
             (button ([class "tab-button"]) "JSON API")
             (button ([class "tab-button"]) "Templates"))
           
           (div ([class "code-block"])
             ,(helper 'highlight-code
                     "#lang ella

;; Basic routing
(get \"/\" \"Hello, World!\")

;; Named parameters
(get \"/hello/:name\" 
  (string-append \"Hello, \" (hash-ref (params) 'name) \"!\"))

;; Query parameters
(get \"/search\"
  (let ([q (hash-ref (params) 'q \"\")])
    (string-append \"Searching for: \" q)))"
                     "racket"))))
       
       ;; Stats Section
       (section ([class "stats"])
         (div ([class "container"])
           (h2 "Trusted by Developers")
           (div ([class "stats-grid"])
             (div ([class "stat-item"])
               (h3 "< 1MB")
               (p "Lightweight"))
             (div ([class "stat-item"])
               (h3 "0")
               (p "Dependencies"))
             (div ([class "stat-item"])
               (h3 "100%")
               (p "Racket"))
             (div ([class "stat-item"])
               (h3 "MIT")
               (p "License")))))
       
       ;; Footer
       (footer ([class "footer"])
         (div ([class "container"])
           (div ([class "footer-content"])
             (div
               (h4 "Framework")
               (p "Ella is a modern web framework for Racket inspired by Sinatra's simplicity and elegance."))
             (div
               (h4 "Resources")
               (p (a ([href "/docs"]) "Documentation"))
               (p (a ([href "/examples"]) "Examples"))
               (p (a ([href "/api"]) "API Reference")))
             (div
               (h4 "Community")
               (p (a ([href "https://github.com/ella-framework/ella"]) "GitHub"))
               (p (a ([href "https://github.com/ella-framework/ella/issues"]) "Issues"))
               (p (a ([href "/contributing"]) "Contributing")))
             (div
               (h4 "Links")
               (p (a ([href "https://racket-lang.org"]) "Racket"))
               (p (a ([href "https://sinatrarb.com"]) "Sinatra"))
               (p (a ([href "/license"]) "License")))))))
    
    "Ella Framework - Lightweight Web Framework for Racket"
    "Ella is a Sinatra-inspired web framework for Racket. Simple, powerful, and elegant."))

;; Routes
(get "/" (html (template 'home-page)))

(get "/docs" 
  (response/output
    #:code 302
    #:headers (list (header #"Location" #"/docs/getting-started"))
    (lambda (out) (display "" out))))

;; Simple example pages
(get "/examples" 
  (html `(html
           (head (title "Examples - Ella Framework"))
           (body
             (h1 "Ella Framework Examples")
             (ul
               (li (a ([href "/examples/hello-world"]) "Hello World"))
               (li (a ([href "/examples/blog"]) "Blog Application"))
               (li (a ([href "/examples/api"]) "REST API"))
               (li (a ([href "/examples/todo"]) "Todo Application")))))))

;; API endpoint for the website itself
(get "/api/info"
  (json-response 
    (hash 'framework "Ella"
          'version "1.0"
          'description "Lightweight web framework for Racket"
          'features (list "routing" "templates" "filters" "helpers" "json" "errors"))))