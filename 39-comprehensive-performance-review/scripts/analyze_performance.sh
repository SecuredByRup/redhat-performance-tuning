#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

DATA_DIR=$(cat "${BASE_DIR}/monitoring/LATEST" 2>/dev/null)
REPORT_DIR="${BASE_DIR}/reports"
mkdir -p "$REPORT_DIR"

if [ -z "$DATA_DIR" ] || [ ! -d "$DATA_DIR" ]; then
    echo "Error: no monitoring data found. Run performance_monitor.sh first."
    exit 1
fi

REPORT_FILE="${REPORT_DIR}/performance_analysis_$(date +%Y%m%d_%H%M%S).txt"

{
echo "Performance Analysis Report - $(date)"
echo "========================================="
echo "Source data: $DATA_DIR"
echo ""

echo "CPU USAGE ANALYSIS"
echo "-------------------"
if [ -f "${DATA_DIR}/top_output.txt" ]; then
    grep "Cpu(s)" "${DATA_DIR}/top_output.txt" | \
        sed -E 's/.*, *([0-9.]+)%? *id.*/\1/' | \
        awk '{idle+=$1; count++} END {
            if (count > 0) {
                avg_idle = idle/count
                avg_busy = 100 - avg_idle
                printf "Average CPU busy: %.2f%%\n", avg_busy
            } else {
                print "No CPU samples parsed."
            }
        }'
else
    echo "top_output.txt not found."
fi
echo ""

echo "MEMORY USAGE ANALYSIS"
echo "----------------------"
if [ -f "${DATA_DIR}/memory_tracking.txt" ]; then
    awk '{total+=$2; used+=$3; count++} END {
        if (count > 0) {
            pct = (used/total)*100
            printf "Average Memory Usage: %.0f MB / %.0f MB (%.1f%%)\n", used/count, total/count, pct
        } else {
            print "No memory samples parsed."
        }
    }' "${DATA_DIR}/memory_tracking.txt"
else
    echo "memory_tracking.txt not found."
fi
echo ""

echo "DISK I/O ANALYSIS"
echo "------------------"
if [ -f "${DATA_DIR}/iostat_output.txt" ]; then
    grep -E "^[a-zA-Z]" "${DATA_DIR}/iostat_output.txt" | grep -Ev "Device|avg-cpu" | \
        awk '{if (NF >= 14) {util += $NF; count++}} END {
            if (count > 0) printf "Average Disk Utilization: %.2f%%\n", util/count
            else print "No iostat device samples parsed."
        }'
else
    echo "iostat_output.txt not found."
fi
echo ""

echo "THRESHOLD-BASED FINDINGS"
echo "-------------------------"
} > "$REPORT_FILE"

cpu_busy=$(grep "Cpu(s)" "${DATA_DIR}/top_output.txt" 2>/dev/null | \
    sed -E 's/.*, *([0-9.]+)%? *id.*/\1/' | \
    awk '{idle+=$1; count++} END {if (count>0) printf "%.1f", 100-(idle/count); else print "0"}')

mem_pct=$(awk '{total+=$2; used+=$3; count++} END {
    if (count>0) printf "%.1f", (used/total)*100; else print "0"
}' "${DATA_DIR}/memory_tracking.txt" 2>/dev/null)

if [ -z "$cpu_busy" ]; then cpu_busy=0; fi
if [ -z "$mem_pct" ]; then mem_pct=0; fi

{
if (( $(echo "$cpu_busy > 70" | bc -l) )); then
    echo "FINDING: High CPU utilization (${cpu_busy}%) - candidate for CPU tuning."
else
    echo "CPU utilization normal (${cpu_busy}%)."
fi

if (( $(echo "$mem_pct > 80" | bc -l) )); then
    echo "FINDING: High memory utilization (${mem_pct}%) - candidate for memory/swappiness tuning."
else
    echo "Memory utilization normal (${mem_pct}%)."
fi
} >> "$REPORT_FILE"

echo "Analysis written to: $REPORT_FILE"
cat "$REPORT_FILE"
