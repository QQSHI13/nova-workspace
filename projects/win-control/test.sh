#!/bin/bash
# Test WinControl Actions API
# Usage: ./test.sh

echo "Testing WinControl Actions API..."
echo ""

# Wait for server to be ready
echo -n "Waiting for server..."
for i in {1..10}; do
    if curl -s http://localhost:8767/ping > /dev/null 2>&1; then
        echo " OK"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

# Get screen info
echo "Screen info:"
curl -s http://localhost:8767/screen | python3 -m json.tool
echo ""

# Test click (center of screen)
echo "Testing click at center..."
curl -s -X POST http://localhost:8767/click \
  -H "Content-Type: application/json" \
  -d '{"x": 640, "y": 360, "button": "left"}' | python3 -m json.tool
echo ""

# Test type
echo "Testing type..."
curl -s -X POST http://localhost:8767/type \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello from WinControl"}' | python3 -m json.tool
echo ""

# Test key
echo "Testing key (Enter)..."
curl -s -X POST http://localhost:8767/key \
  -H "Content-Type: application/json" \
  -d '{"key": "Enter"}' | python3 -m json.tool
echo ""

# Test combo (Ctrl+C)
echo "Testing combo (Ctrl+C)..."
curl -s -X POST http://localhost:8767/combo \
  -H "Content-Type: application/json" \
  -d '{"keys": ["Ctrl", "C"]}' | python3 -m json.tool
echo ""

echo "All tests complete!"
