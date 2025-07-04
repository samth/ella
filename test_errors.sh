#!/bin/bash

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

echo "Testing custom 404 error page:"
curl http://localhost:8080/nonexistent-page
echo
echo

echo "Testing custom 500 error page:"
curl http://localhost:8080/error-test
echo

# Kill the server process
kill $SERVER_PID