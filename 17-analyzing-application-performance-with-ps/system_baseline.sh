#!/bin/bash
BASELINE_FILE="system_baseline_$(date +%Y%m%d).txt"
echo "Creating system performance baseline: $BASELINE_FILE"

{
    echo "=== SYSTEM PERFORMANCE BASELINE ==="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "CPU Cores: $(nproc)"
    echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    echo
    echo "=== CURRENT LOAD ==="
    uptime
    echo
    echo "=== TOP 10 PROCESSES BY CPU ==="
    ps aux --sort=-%cpu | head -11
} > "$BASELINE_FILE"

echo "Baseline saved to: $BASELINE_FILE"
