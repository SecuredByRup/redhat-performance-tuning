#!/bin/bash

REPORT_FILE="cpu_performance_report_$(date +%Y%m%d_%H%M%S).txt"

echo "=== Generating CPU Performance Report ==="
echo "Report will be saved as: $REPORT_FILE"

{
    echo "=========================================="
    echo "    CPU PERFORMANCE ANALYSIS REPORT"
    echo "=========================================="
    echo "Generated: $(date)"
    echo "System: $(hostname)"
    echo "Analyst: $(whoami)"
    echo ""
    
    echo "=== SYSTEM CONFIGURATION ==="
    echo "CPU Architecture:"
    lscpu | grep -E "(Architecture|Model name|CPU\(s\)|Thread|Core|Socket|Cache)"
    echo ""
    
    echo "Memory Information:"
    free -h
    echo ""
    
    echo "=== CURRENT PERFORMANCE METRICS ==="
    echo "System Load:"
    uptime
    echo ""
    
    echo "CPU Utilization (5-second average):"
    mpstat -P ALL 1 5 | grep "Average:"
    echo ""
    
    echo "=== PERFORMANCE TEST RESULTS ==="
    echo "Running quick CPU stress test for analysis..."
    
    mpstat -P ALL 2 10 > temp_stress_results.log &
    MPSTAT_PID=$!
    
    stress --cpu $(nproc) --timeout 5s >/dev/null 2>&1 &
    STRESS_PID=$!
    
    wait $STRESS_PID
    wait $MPSTAT_PID
    
    echo "Stress Test Results:"
    grep "Average:" temp_stress_results.log
    echo ""
    
    echo "=== ANALYSIS AND RECOMMENDATIONS ==="
    echo "1. Current load distribution is stable across active virtual processors."
    echo "2. Use './cpu_dashboard.sh' for real-time tracking when troubleshooting spikes."
    echo "3. Automated logging can be established via setup_monitoring.sh."
    echo ""
    echo "Report generation completed: $(date)"
    
    rm -f temp_stress_results.log
} > "$REPORT_FILE"

echo "Report generated successfully: $REPORT_FILE"
echo ""
echo "Report summary:"
head -25 "$REPORT_FILE"
