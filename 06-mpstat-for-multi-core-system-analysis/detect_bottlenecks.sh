#!/bin/bash

echo "=== CPU Bottleneck Detection ==="

# Function to analyze CPU metrics
analyze_cpu_metrics() {
    local logfile=$1
    
    echo "Analyzing CPU metrics from $logfile"
    echo ""
    
    # Calculate average utilization per CPU (CPU is in $2, %usr in $3, %sys in $5)
    echo "=== Average CPU Utilization per Core ==="
    awk '
    /Average:/ && $2 ~ /^[0-9]+$/ {
        cpu = $2
        usr = $3
        sys = $5
        total = usr + sys
        printf "CPU %s: User=%.1f%% System=%.1f%% Total=%.1f%%\n", cpu, usr, sys, total
    }
    ' $logfile
    
    echo ""
    
    # Identify imbalanced cores
    echo "=== Load Imbalance Detection ==="
    awk '
    /Average:/ && $2 ~ /^[0-9]+$/ {
        cpu = $2
        total = $3 + $5  # usr + sys
        if (total > 80) print "HIGH LOAD: CPU " cpu " at " total "%"
        else if (total < 10) print "LOW LOAD: CPU " cpu " at " total "%"
    }
    ' $logfile
    
    echo ""
    
    # Check for I/O wait issues (%iowait is typically in $6)
    echo "=== I/O Wait Analysis ==="
    awk '
    /Average:/ && $2 ~ /^[0-9]+$/ {
        cpu = $2
        iowait = $6
        if (iowait > 20) print "HIGH I/O WAIT: CPU " cpu " at " iowait "%"
    }
    ' $logfile
}

# Run analysis on existing log
if [ -f "cpu_stats.log" ]; then
    analyze_cpu_metrics "cpu_stats.log"
else
    echo "No existing log found. Generating new data..."
    mpstat -P ALL 2 15 > temp_cpu_stats.log
    analyze_cpu_metrics "temp_cpu_stats.log"
fi
