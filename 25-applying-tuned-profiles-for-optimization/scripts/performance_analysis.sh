#!/bin/bash

REPORT_FILE="tuned_performance_report.txt"

echo "=== Comprehensive Tuned Profile Performance Analysis ===" > "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "System: $(uname -a)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== Profile Configuration Summary ===" >> "$REPORT_FILE"
for profile in balanced throughput-performance virtual-guest custom-lab-profile; do
    echo "--- $profile ---" >> "$REPORT_FILE"
    if [ -f tuned_performance_data/${profile}_*.log ]; then
        latest_file=$(ls -t tuned_performance_data/${profile}_*.log | head -1)
        echo "CPU Governor: $(grep -A1 "CPU Governor" "$latest_file" | tail -1)" >> "$REPORT_FILE"
        echo "I/O Scheduler: $(grep -A1 "I/O Scheduler" "$latest_file" | tail -1)" >> "$REPORT_FILE"
        echo "vm.swappiness: $(grep "vm.swappiness" "$latest_file")" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
done

echo "=== Performance Test Results Summary ===" >> "$REPORT_FILE"
for profile in balanced throughput-performance virtual-guest custom-lab-profile; do
    echo "--- $profile Stress Test Results ---" >> "$REPORT_FILE"
    if [ -f stress_results_${profile}.log ]; then
        echo "Average Load:" >> "$REPORT_FILE"
        grep "Load:" stress_results_${profile}.log | awk -F': ' '{print $2}' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
done

echo "Performance analysis report generated: $REPORT_FILE"
