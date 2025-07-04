# Ella Framework Examples

This directory contains example applications demonstrating various features of the Ella framework.

## Examples

### 1. Hello World (`hello-world.rkt`)

The simplest possible Ella application demonstrating basic routing and named parameters.

**Features:**
- Basic GET routes
- Named parameters (`:name`)
- String responses

**Run:**
```bash
racket hello-world.rkt
```

**Try:**
- `http://localhost:8080/` - Hello World
- `http://localhost:8080/hello/Alice` - Personalized greeting

---

### 2. Blog (`blog.rkt`)

A simple blog application with multiple pages and content management.

**Features:**
- Template system with layouts
- Helper functions (date formatting, text truncation)
- Route parameters
- Custom 404 pages
- CSS styling

**Run:**
```bash
racket blog.rkt
```

**Try:**
- `http://localhost:8080/` - Home page with post list
- `http://localhost:8080/posts/1` - Individual post
- `http://localhost:8080/about` - About page
- `http://localhost:8080/nonexistent` - Custom 404 page

---

### 3. API Server (`api-server.rkt`)

A RESTful API server demonstrating JSON responses and HTTP methods.

**Features:**
- JSON responses
- RESTful API design
- CORS headers (after filters)
- Request logging (before filters)
- Error handling
- API documentation

**Run:**
```bash
racket api-server.rkt
```

**Try:**
- `http://localhost:8080/` - API documentation
- `http://localhost:8080/api/users` - List users
- `http://localhost:8080/api/users/1` - Get specific user
- `http://localhost:8080/api/health` - Health check

**API Endpoints:**
- `GET /api/users` - List all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user (name, email)
- `PUT /api/users/:id` - Update user
- `PATCH /api/users/:id/delete` - Delete user

**Example API Usage:**
```bash
# List users
curl http://localhost:8080/api/users

# Create user  
curl -X POST -d "name=John&email=john@example.com" http://localhost:8080/api/users

# Get specific user
curl http://localhost:8080/api/users/1

# Update user
curl -X PUT -d "name=Jane&email=jane@example.com" http://localhost:8080/api/users/1
```

---

### 4. Todo App (`todo-app.rkt`)

A full-featured todo application with forms, dynamic content, and state management.

**Features:**
- Form handling (POST requests)
- Dynamic content updates
- State management (in-memory store)
- CSS styling and responsive design
- Statistics and filtering
- CRUD operations
- Redirects after form submission
- Confirmation dialogs

**Run:**
```bash
racket todo-app.rkt
```

**Try:**
- `http://localhost:8080/` - Main todo list
- `http://localhost:8080/pending` - Pending todos only
- `http://localhost:8080/completed` - Completed todos only
- Add new todos using the form
- Toggle completion by checking/unchecking
- Delete todos with the delete button
- `http://localhost:8080/api/todos` - JSON API endpoint

---

## Running Examples

Each example is a complete, standalone application. To run any example:

1. Make sure you have the Ella framework installed
2. Navigate to the examples directory
3. Run the example with Racket:
   ```bash
   racket example-name.rkt
   ```
4. Open your browser to `http://localhost:8080`

## Learning Path

We recommend exploring the examples in this order:

1. **hello-world.rkt** - Learn basic routing and responses
2. **blog.rkt** - Understand templates, layouts, and helpers  
3. **api-server.rkt** - Explore JSON APIs and HTTP methods
4. **todo-app.rkt** - See a complete application with forms and state

## Customizing Examples

Each example is self-contained and can be modified to experiment with different features:

- Change routes and add new endpoints
- Modify templates and styling
- Add new helper functions
- Experiment with different response types
- Add authentication and sessions
- Connect to external databases

## Next Steps

After exploring these examples, check out:

- [Getting Started Guide](../docs/getting-started.md)
- [API Reference](../API.md)
- [Templates Documentation](../docs/templates.md)
- [Filters and Helpers Guide](../docs/filters-helpers.md)

Happy coding with Ella!