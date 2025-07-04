#!/bin/bash

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

echo "Testing Scribble template support:"
curl http://localhost:8080/scribble-demo
echo

# Kill the server process
kill $SERVER_PID