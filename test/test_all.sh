#!/bin/bash

echo "Running comprehensive tests for Ella web framework..."
echo

echo "1. Running unit tests..."
raco test main.rkt
echo

echo "2. Testing named parameters..."
bash test/test_server.sh
echo

echo "3. Testing splat parameters..."
bash test/test_splat.sh
echo

echo "4. Testing query parameters..."
bash test/test_query.sh
echo

echo "5. Testing JSON responses..."
bash test/test_json.sh
echo

echo "6. Testing template system with layouts..."
bash test/test_template.sh
echo

echo "All tests completed!"
