#!/bin/bash

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

# Test filters with user route
echo "Testing filters with user route:"
curl -I http://localhost:8080/user/456
echo

curl http://localhost:8080/user/456

# Kill the server process
kill $SERVER_PID