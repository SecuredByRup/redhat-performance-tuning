#!/bin/bash
echo "=== CPU BOTTLENECK DETECTION ==="
CPU_CORES=$(nproc)
LOAD_1MIN=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
echo "System has $CPU_CORES CPU cores. Current load 1min: $LOAD_1MIN"
if (( $(echo "$LOAD_1MIN > $CPU_CORES" | bc -l) )); then
    echo "WARNING: CPU bottleneck detected!"
else
    echo "CPU load is within normal range"
fi
