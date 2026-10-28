#!/bin/bash

HOSTS=("localhost" "target-1" "target-2")

echo "=== PCP System Statistics Overview ==="
for host in "${HOSTS[@]}"; do
    echo "----------------------------------------"
    echo "System Statistics for: $host"
    echo "----------------------------------------"
    pmstat -h $host -t 2 -s 3
    echo ""
done
