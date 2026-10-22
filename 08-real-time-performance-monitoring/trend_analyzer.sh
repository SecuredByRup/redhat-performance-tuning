#!/bin/bash
# Advanced Trend Analyzer & Report Generator
LOG_DIR="monitoring_logs"

echo "=== CPU TREND ANALYSIS ==="
CPU_LOG=$(ls -t "$LOG_DIR"/cpu_*.log 2>/dev/null | head -1)

if [ -z "$CPU_LOG" ] || [ ! -f "$CPU_LOG" ]; then
    echo "No CPU log files found in $LOG_DIR. Run cpu_monitor.sh first."
    exit 1
fi

echo "Analyzing CPU data from: $CPU_LOG"
# Calculate average and peaks using awk
AVG_CPU=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}' "$CPU_LOG")
MAX_CPU=$(awk -F',' 'NR>1 {if($2>max || NR==2) max=$2} END {print max}' "$CPU_LOG")
MIN_CPU=$(awk -F',' 'NR>1 {if($2<min || NR==2) min=$2} END {print min}' "$CPU_LOG")

echo "Average CPU Usage: ${AVG_CPU}%"
echo "Maximum CPU Usage: ${MAX_CPU}%"
echo "Minimum CPU Usage: ${MIN_CPU}%"

echo ""
echo "=== ALERT SUMMARY ==="
if (( $(echo "$MAX_CPU > 80.0" | bc -l) )); then
    echo "[ALERT] Peak CPU usage exceeded 80% threshold!"
else
    echo "No critical alerts triggered during the monitoring window."
fi

echo "Trend analysis completed successfully."
