# Racket Web Framework Development Plan (Ella)

This document outlines the development plan for a Racket web framework inspired by Sinatra, along with the progress made and challenges encountered so far.

## Project Goal

To build a lightweight and intuitive web framework in Racket, similar in spirit and API to Ruby's Sinatra.

## Initial State (Based on `sinatra-intro.html`, `example.rkt`, `main.rkt`)

*   **`sinatra-intro.html`**: Provides a detailed overview of Sinatra's features, serving as a blueprint for the Racket framework. Key features highlighted include routing (named parameters, splats, regex), conditions, return values, templates, filters, helpers, sessions, error handling, Rack middleware, and testing.
*   **`example.rkt`**: A basic example demonstrating a `get` route.
*   **`main.rkt`**: Contains the initial implementation of the framework, including:
    *   `get`, `post`, `put`, `patch` macros for defining routes.
    *   A `router-tbl` to store routes.
    *   `route` struct to hold pattern, method, and handler.
    *   Basic `serve/servlet` setup.
    *   Initial `find-route`, `matches?`, `path-matches?` functions.
    *   A `params` parameter for accessing request parameters.

## Development Plan

### Phase 1: Core Functionality (Alpha)

Focuses on building the essential features of the framework, making it usable for basic web applications.

1.  **Improve Routing:**
    *   **Named Parameters:** Implement Sinatra-style named parameters in routes (e.g., `/hello/:name`). This involves:
        *   Updating `parse-route` to recognize and convert these patterns into regular expressions.
        *   Modifying `path-matches?` to handle the new route patterns.
        *   Extracting the values of the named parameters from the URL and adding them to the `params` hash.
    *   **Splat/Wildcard Parameters:** Add support for wildcard parameters (e.g., `/say/*/to/*`) to capture multiple parts of a URL.
2.  **Enhance Parameter Handling:**
    *   **Unified `params`:** Consolidate all request parameters (URL query parameters, named route parameters, and POST body parameters) into a single, easily accessible `params` hash, similar to Sinatra.
3.  **Expand Response Handling:**
    *   **JSON Support:** Add built-in support for returning JSON responses. This will involve using the `racket/json` library to automatically convert Racket data structures to JSON.
    *   **Content-Type Headers:** Implement a helper function to easily set the `Content-Type` header of the response (e.g., `(content-type 'json)`).
4.  **Basic Templating:**
    *   **Xexpr Templates:** Create a simple and intuitive system for rendering templates using Racket's native `xexpr`s (XML expressions). This will allow developers to write templates directly in Racket code.
    *   **Layouts:** Implement a basic layout system, allowing templates to be nested within a main layout file.
5.  **Testing:**
    *   **Test Suite:** Establish a robust test suite using `rackunit`.
    *   **Coverage:** Write tests for all the new features, including routing, parameter handling, and response generation.

### Phase 2: Feature Expansion (Beta)

Adds more advanced features to the framework, making it more powerful and flexible.

1.  **Filters:**
    *   **`before` Filters:** Implement `before` filters that run before each request. These filters will be able to modify the request and set instance variables.
    *   **`after` Filters:** Implement `after` filters that run after each request. These filters will be able to modify the response.
2.  **Helpers:**
    *   **Helper System:** Create a system for defining and using helper functions within routes and templates, similar to Sinatra's `helpers` block.
3.  **Advanced Templating:**
    *   **Additional Template Engines:** Explore and integrate support for other Racket template engines, such as Scribble, to provide more options for developers.
4.  **Error Handling:**
    *   **Custom Error Pages:** Implement a mechanism for defining custom error pages for different HTTP status codes (e.g., 404, 500).
    *   **Exception Handling:** Improve the exception handling to provide more informative error messages during development.

### Phase 3: Refinement and Documentation (1.0)

Focuses on polishing the framework, making it ready for a stable release.

1.  **Code Refactoring:**
    *   **Modularity:** Refactor the codebase to be more modular and extensible, making it easier to maintain and add new features in the future.
    *   **API Design:** Review and refine the public API of the framework to ensure it is consistent, intuitive, and well-documented.
2.  **Documentation:**
    *   **Comprehensive Guides:** Write comprehensive documentation, including tutorials, guides, and API references.
    *   **Examples:** Create a rich collection of examples to showcase the framework's features and demonstrate how to build different types of web applications.
3.  **Packaging and Distribution:**
    *   **Racket Package:** Package the framework as a Racket package, so it can be easily installed and used by other developers.
    *   **Community Building:** Create a community around the framework by setting up a mailing list, a forum, or a chat room.

## Progress and Challenges (Phase 1: Improve Routing - Named Parameters)

**Goal:** Implement named parameters in routes (e.g., `/hello/:name`) and populate the `params` hash.

**Progress:**

*   **`route` struct updated**: The `route` struct in `main.rkt` was modified to include `param-names` to store the names of captured parameters.
*   **`parse-route` enhanced**: The `parse-route` function was updated to:
    *   Identify named parameters (e.g., `:name`) in route strings.
    *   Convert these into regular expression capture groups (`([^/]+)`).
    *   Handle leading slashes in route patterns to ensure correct regex generation.
    *   Use `byte-regexp` for creating byte-string regular expressions, as `regexp-match` expects them.
*   **`start` function modified**: The `start` function was updated to:
    *   Extract captured values from the `regexp-match` result (`mtch`).
    *   Associate these captured values with their corresponding parameter names.
    *   Store the named parameters (converted to UTF-8 strings) in the `current-params` hash.
*   **`example.rkt` updated**: An example route `(get "/hello/:name" (string-append "Hello, " (hash-ref (params) 'name)))` was added to test the named parameter functionality.
*   **Testing Script (`test_server.sh`)**: A shell script was created to safely start the Racket server, make a `curl` request, and then terminate the server process. This ensures a controlled testing environment.

**Challenges Encountered:**

1.  **Missing Racket Imports**: Initially, `string-split` and `regexp` functions were unbound. This was resolved by adding `(require racket/string)` and ensuring `regexp` was used correctly (it's built-in, not from a separate module).
2.  **Incorrect Path Extraction**: The `matches?` function was initially using `request-path` incorrectly, leading to type errors. This was corrected to use `(apply build-path "/" (map path/param-path (url-path (request-uri req))))` to correctly construct the path string.
3.  **Regex Generation for Named Parameters**:
    *   **Leading Slash Handling**: `string-split` removes leading slashes, which caused the generated regex to be incorrect. This was addressed by explicitly checking for and re-adding the leading slash (`^/`) to the regex string in `parse-route`.
    *   **Byte String Mismatch**: `regexp-match` expects a byte string for the regex when the regex itself is a byte-regexp. Initially, `regexp` was used, which creates a string-regex. Switching to `byte-regexp` and converting the regex string to a byte string (`string->bytes/utf-8`) resolved this.
    *   **Captured Value Type**: `regexp-match` returns captured groups as byte strings. The `params` hash was initially storing these as raw byte strings, leading to errors when `example.rkt` tried to concatenate them with regular strings. This was resolved by converting the captured byte strings to UTF-8 strings (`bytes->string/utf-8`) before storing them in the `params` hash in `main.rkt`.
4.  **Persistent `bytes->string/utf8` Unbound Error**: This was a recurring and challenging issue. Despite `racket/string` being imported, `bytes->string/utf8` was consistently reported as unbound within `main.rkt`. Multiple attempts to explicitly import it (e.g., `only-in`, `for-all`) or wrap it in helper functions failed. The current workaround is to perform the `bytes->string/utf8` conversion directly when populating the `params` hash in `main.rkt`, and ensure `example.rkt` does not attempt to convert it again. This indicates a deeper, unresolved Racket environment or module resolution issue that needs further investigation if it impacts future development.

**Current Status:**

*   Basic string-based routing works.
*   Named parameter routing is still failing with a "Not Found" error. The debugging output indicates that `regexp-match` is still returning `#f`, even though the regex and path appear correct. The `printf` statements in `matches?` and `path-matches?` confirm the inputs to `regexp-match` are as expected. The issue is likely a subtle interaction with `regexp-match` or the Racket environment that is not immediately apparent.

## Next Steps

The immediate next step is to resolve the persistent "Not Found" error for named parameters. This will require further in-depth debugging of the `regexp-match` behavior within the Racket environment.
