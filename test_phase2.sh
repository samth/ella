#!/bin/bash

echo "======================================"
echo "ELLA FRAMEWORK - PHASE 2 DEMO"
echo "======================================"
echo

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

echo "1. Testing BEFORE/AFTER FILTERS:"
echo "   (Check terminal output for REQUEST logs and X-Powered-By header)"
curl -I http://localhost:8080/user/123 | grep "X-Powered-By"
echo

echo "2. Testing HELPER SYSTEM:"
echo "   (Date formatting, pluralization, text truncation)"
curl http://localhost:8080/user/456 | grep -o "Request timestamp: [^<]*"
echo

echo "3. Testing CUSTOM ERROR PAGES:"
echo "   Custom 404 page:"
curl http://localhost:8080/nonexistent | grep -o "<h2>[^<]*</h2>"
echo "   Custom 500 page:"
curl http://localhost:8080/error-test | grep -o "<h2>[^<]*</h2>"
echo

echo "4. Testing SCRIBBLE TEMPLATE ENGINE:"
echo "   (Markup conversion: title, section, para, bold, lists, links)"
curl http://localhost:8080/scribble-demo | grep -o "<h1>[^<]*</h1>"
curl http://localhost:8080/scribble-demo | grep -o "<strong>[^<]*</strong>"
curl http://localhost:8080/scribble-demo | grep -o "<ul>.*</ul>"
echo

echo "5. Testing EXCEPTION HANDLING:"
echo "   Graceful error handling with custom pages"
curl -o /dev/null -s -w "HTTP Status: %{http_code}\n" http://localhost:8080/error-test
echo

# Kill the server process
kill $SERVER_PID

echo "======================================"
echo "PHASE 2 FEATURES COMPLETED:"
echo "✅ Before/After Filters"
echo "✅ Helper System"  
echo "✅ Custom Error Pages"
echo "✅ Exception Handling"
echo "✅ Scribble Template Support"
echo "======================================"