#!/bin/bash

echo "Comparative Performance Analysis"
echo "==============================="

HOSTS=("localhost" "target-1" "target-2")
METRICS=("kernel.all.cpu.user" "mem.util.used" "kernel.all.load")

for metric in "${METRICS[@]}"; do
    echo ""
    echo "Metric: $metric"
    echo "--------------------------------------------------"
    
    for host in "${HOSTS[@]}"; do
        value=$(pminfo -h "$host" -f "$metric" 2>/dev/null | grep value | awk '{print $2}' | head -1)
        if [ -n "$value" ]; then
            printf "%-12s: %s\n" "$host" "$value"
        else
            printf "%-12s: N/A\n" "$host"
        fi
    done
done

echo ""
echo "Comparative analysis complete!"
