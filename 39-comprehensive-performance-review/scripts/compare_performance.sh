#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "PERFORMANCE COMPARISON ANALYSIS"
echo "================================="

BASELINE_DIR=$(cat "${BASE_DIR}/monitoring/LATEST" 2>/dev/null)
POST_DIR=$(cat "${BASE_DIR}/post_tuning/LATEST" 2>/dev/null)

if [ -z "$BASELINE_DIR" ] || [ ! -d "$BASELINE_DIR" ]; then
    echo "Error: baseline monitoring data not found. Run performance_monitor.sh first."
    exit 1
fi

if [ -z "$POST_DIR" ] || [ ! -d "$POST_DIR" ]; then
    echo "Error: post-tuning data not found. Run post_tuning_test.sh first."
    exit 1
fi

REPORT_DIR="${BASE_DIR}/reports"
mkdir -p "$REPORT_DIR"
COMPARISON_REPORT="${REPORT_DIR}/performance_comparison_$(date +%Y%m%d_%H%M%S).txt"

calc_cpu_busy() {
    local file="$1/top_output.txt"
    if [ -f "$file" ]; then
        grep "Cpu(s)" "$file" | sed -E 's/.*, *([0-9.]+)%? *id.*/\1/' | \
            awk '{idle+=$1; count++} END {if (count>0) printf "%.2f", 100-(idle/count); else print "0.00"}'
    else
        echo "0.00"
    fi
}

calc_mem_pct() {
    local file="$1/memory_tracking.txt"
    if [ -f "$file" ]; then
        awk '{total+=$2; used+=$3; count++} END {
            if (count>0) printf "%.2f", (used/total)*100; else print "0.00"
        }' "$file"
    else
        echo "0.00"
    fi
}

calc_disk_util() {
    local file="$1/iostat_output.txt"
    if [ -f "$file" ]; then
        grep -E "^[a-zA-Z]" "$file" | grep -Ev "Device|avg-cpu" | \
            awk '{if (NF >= 14) {util += $NF; count++}} END {
                if (count>0) printf "%.2f", util/count; else print "0.00"
            }'
    else
        echo "0.00"
    fi
}

baseline_cpu=$(calc_cpu_busy "$BASELINE_DIR")
post_cpu=$(calc_cpu_busy "$POST_DIR")
baseline_mem=$(calc_mem_pct "$BASELINE_DIR")
post_mem=$(calc_mem_pct "$POST_DIR")
baseline_disk=$(calc_disk_util "$BASELINE_DIR")
post_disk=$(calc_disk_util "$POST_DIR")

cpu_delta=$(echo "$post_cpu - $baseline_cpu" | bc)
mem_delta=$(echo "$post_mem - $baseline_mem" | bc)
disk_delta=$(echo "$post_disk - $baseline_disk" | bc)

cat > "$COMPARISON_REPORT" << REPORT_EOF
PERFORMANCE COMPARISON REPORT
==============================
Generated: $(date)
Baseline source:    $BASELINE_DIR
Post-tuning source: $POST_DIR

METRIC              BASELINE     POST-TUNING     DELTA
------              --------     -----------     -----
CPU Busy (%)        ${baseline_cpu}         ${post_cpu}            ${cpu_delta}
Memory Used (%)     ${baseline_mem}         ${post_mem}            ${mem_delta}
Disk Utilization(%) ${baseline_disk}         ${post_disk}            ${disk_delta}
REPORT_EOF

echo "Comparison report saved to: $COMPARISON_REPORT"
cat "$COMPARISON_REPORT"
