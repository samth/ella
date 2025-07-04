#!/bin/bash

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

# Test JSON response
echo "Testing JSON response:"
curl -H "Accept: application/json" http://localhost:8080/api/user/123

# Kill the server process
kill $SERVER_PID