#!/bin/bash

SERVICE_NAME=${1:-"httpd"}
DURATION=${2:-30}

echo "Monitoring $SERVICE_NAME for $DURATION seconds..."

PID=$(pgrep $SERVICE_NAME | head -1)

if [ -z "$PID" ]; then
    echo "Service $SERVICE_NAME not found. Starting a test process..."
    python3 -m http.server 8080 &
    PID=$!
    echo "Started test HTTP server with PID: $PID"
    sleep 2
fi

echo "Tracing PID: $PID"
timeout $DURATION strace -c -p $PID 2> service_trace.txt

echo "Monitoring completed. Results:"
cat service_trace.txt

if [ "$SERVICE_NAME" = "httpd" ] && jobs %1 2>/dev/null; then
    kill $PID 2>/dev/null
fi
