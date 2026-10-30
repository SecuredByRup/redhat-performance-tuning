#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

REPORT_DIR="${BASE_DIR}/reports"
LATEST_ANALYSIS=$(ls -1t "$REPORT_DIR"/performance_analysis_*.txt 2>/dev/null | head -1)
LATEST_COMPARISON=$(ls -1t "$REPORT_DIR"/performance_comparison_*.txt 2>/dev/null | head -1)
FINAL_REPORT="$REPORT_DIR/FINAL_SUMMARY_$(date +%Y%m%d_%H%M%S).txt"

if [ -z "$LATEST_ANALYSIS" ] || [ -z "$LATEST_COMPARISON" ]; then
    echo "Error: run analyze_performance.sh and compare_performance.sh first."
    exit 1
fi

{
echo "LAB 39 FINAL PERFORMANCE REVIEW SUMMARY"
echo "========================================"
echo "Generated: $(date)"
echo ""
echo "----- BASELINE ANALYSIS -----"
cat "$LATEST_ANALYSIS"
echo ""
echo "----- BEFORE/AFTER COMPARISON -----"
cat "$LATEST_COMPARISON"
} > "$FINAL_REPORT"

echo "Final summary written to: $FINAL_REPORT"
