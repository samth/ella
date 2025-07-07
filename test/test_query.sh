#!/bin/bash

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

# Test query parameters
echo "Testing query parameters:"
curl "http://localhost:8080/greet?name=Alice"

# Kill the server process
kill $SERVER_PID