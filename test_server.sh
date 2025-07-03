#!/bin/bash

# Start the server in the background
racket example.rkt &

# Get the process ID of the server
SERVER_PID=$!

# Wait for the server to start
sleep 2

# Test the server with curl
curl http://localhost:8080/hello/world

# Kill the server process
kill $SERVER_PID
