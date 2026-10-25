#!/bin/bash
echo "=== Bottleneck Analysis Tool ==="

# CPU Check
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "Current CPU usage: ${cpu_usage}%"
if (( $(echo "$cpu_usage > 80" | bc -l) )); then
    echo "⚠️ HIGH CPU USAGE DETECTED"
else
    echo "✅ CPU usage normal"
fi

# Memory Check
memory_info=$(free | grep Mem)
total_mem=$(echo $memory_info | awk '{print $2}')
used_mem=$(echo $memory_info | awk '{print $3}')
memory_percent=$(echo "scale=2; $used_mem * 100 / $total_mem" | bc)
echo "Memory usage: ${memory_percent}%"
if (( $(echo "$memory_percent > 85" | bc -l) )); then
    echo "⚠️ HIGH MEMORY USAGE DETECTED"
else
    echo "✅ Memory usage normal"
fi
