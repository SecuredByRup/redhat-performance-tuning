#!/bin/bash
echo "=== MEMORY BOTTLENECK DETECTION ==="
TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
USED_MEM=$(free -m | awk 'NR==2{print $3}')
MEM_USAGE_PERCENT=$((USED_MEM * 100 / TOTAL_MEM))
echo "Used Memory: ${USED_MEM}MB (${MEM_USAGE_PERCENT}%)"
if [ $MEM_USAGE_PERCENT -gt 80 ]; then
    echo "WARNING: High memory usage detected!"
else
    echo "Memory usage is within normal range"
fi
