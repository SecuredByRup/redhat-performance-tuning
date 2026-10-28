#!/bin/bash

# Performance Monitoring Script
# Usage: ./performance_monitor.sh [duration_in_minutes]

DURATION=${1:-3}
INTERVAL=60
ITERATIONS=$((DURATION))
LOGDIR="$HOME/redhat-performance-tuning/22-setting-up-performance-monitoring-tools/performance_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create log directory
mkdir -p "$LOGDIR"

echo "Starting performance monitoring for $DURATION minutes..."
echo "Logs will be saved in: $LOGDIR"

# CPU monitoring
sar -u $INTERVAL $ITERATIONS > "$LOGDIR/cpu_$TIMESTAMP.log" &

# Memory monitoring
sar -r $INTERVAL $ITERATIONS > "$LOGDIR/memory_$TIMESTAMP.log" &

# Disk I/O monitoring
iostat -x $INTERVAL $ITERATIONS > "$LOGDIR/disk_$TIMESTAMP.log" &

# Network monitoring
sar -n DEV $INTERVAL $ITERATIONS > "$LOGDIR/network_$TIMESTAMP.log" &

# Comprehensive system monitoring with dstat
dstat -cdnm --output "$LOGDIR/system_$TIMESTAMP.csv" $INTERVAL $ITERATIONS &

# Wait for all background processes to complete
wait

echo "Performance monitoring completed!"
echo "Check logs in: $LOGDIR"
