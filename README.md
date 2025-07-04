# Ella Framework

A lightweight, Sinatra-inspired web framework for Racket that makes web development simple and elegant.

## Features

- 🚀 **Simple Routing** - Express-style routing with named and splat parameters
- 🎨 **Flexible Templates** - Built-in Xexpr and Scribble template support  
- 🔧 **Powerful Filters** - Before/after filters for request/response processing
- 🧰 **Helper System** - Reusable helper functions for templates and routes
- 📝 **JSON Support** - Built-in JSON response handling
- ⚡ **Error Handling** - Custom error pages and graceful exception handling
- 🏗️ **Modular Design** - Clean, extensible architecture

## Quick Start

```racket
#lang ella

(get "/hello/:name" 
  (string-append "Hello, " (hash-ref (params) 'name) "!"))

(get "/api/users" 
  (json-response (hash 'users '("Alice" "Bob" "Charlie"))))
```

## Installation

```bash
raco pkg install ella
```

## Documentation

- [Getting Started](docs/getting-started.md)
- [Routing Guide](docs/routing.md)
- [Templates and Layouts](docs/templates.md)
- [Filters and Helpers](docs/filters-helpers.md)
- [API Reference](API.md)

## Examples

See the [examples/](examples/) directory for complete example applications.

## Requirements

- Racket 8.0 or later
- web-server-lib
- json

## License

MIT License

## Contributing

Pull requests welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
