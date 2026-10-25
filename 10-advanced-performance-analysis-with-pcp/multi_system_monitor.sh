#!/bin/bash

# Multi-System Performance Monitor
HOSTS=("localhost" "target-1" "target-2")
DURATION=15
INTERVAL=2

echo "Starting multi-system performance monitoring..."
echo "Duration: ${DURATION}s, Interval: ${INTERVAL}s"
echo "=========================================="

for host in "${HOSTS[@]}"; do
    echo "----------------------------------------"
    echo "Monitoring Host: $host"
    echo "----------------------------------------"
    
    # CPU Monitoring
    echo "-> CPU Usage:"
    pmval -h $host -s 2 -t $INTERVAL kernel.all.cpu.user kernel.all.cpu.sys kernel.all.cpu.idle
    
    # Memory Monitoring
    echo "-> Memory Usage:"
    pmval -h $host -s 2 -t $INTERVAL mem.util.used mem.util.free
    
    # Load Average
    echo "-> Load Average:"
    pmval -h $host -s 2 -t $INTERVAL kernel.all.load
    echo ""
done

echo "Multi-system monitoring completed successfully!"
