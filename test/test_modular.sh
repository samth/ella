#!/bin/bash

echo "Testing modular version of Ella framework..."

# Start the server in the background
racket example-modular.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

echo "Testing modular endpoint:"
curl http://localhost:8080/test
echo

# Kill the server process
kill $SERVER_PID

echo "Modular test completed!"