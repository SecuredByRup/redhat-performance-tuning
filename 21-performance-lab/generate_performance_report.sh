#!/bin/bash

REPORT_FILE="performance_tuning_report.txt"

echo "=== Performance Tuning Lab Report ===" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "System: $(uname -a)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "1. SYSTEM BASELINE" >> $REPORT_FILE
echo "==================" >> $REPORT_FILE
cat baseline_report.txt >> $REPORT_FILE 2>/dev/null || echo "Baseline report not found" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "2. BOTTLENECK ANALYSIS" >> $REPORT_FILE
echo "======================" >> $REPORT_FILE
./analyze_bottlenecks.sh >> $REPORT_FILE 2>/dev/null
echo "" >> $REPORT_FILE

echo "3. PERFORMANCE TUNING RECOMMENDATIONS" >> $REPORT_FILE
echo "=====================================" >> $REPORT_FILE
echo "• CPU Optimization: Monitor process priorities with 'nice' and 'renice'." >> $REPORT_FILE
echo "• Memory Optimization: Tune kernel parameters in /proc/sys/vm/." >> $REPORT_FILE
echo "• Disk I/O Optimization: Adjust I/O schedulers based on workloads." >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Report generated successfully: $REPORT_FILE"
