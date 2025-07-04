#!/bin/bash

echo "Starting Ella Framework Website..."

# Start the website server
racket index.rkt &

# Get the process ID
SERVER_PID=$!

# Wait for server to start
sleep 3

echo "Website running at http://localhost:8080"
echo "Opening in browser..."

# Try to open in browser (works on most systems)
if command -v open >/dev/null; then
    open http://localhost:8080
elif command -v xdg-open >/dev/null; then
    xdg-open http://localhost:8080
elif command -v start >/dev/null; then
    start http://localhost:8080
fi

echo "Press Enter to stop the server..."
read

# Stop the server
kill $SERVER_PID
echo "Website stopped."