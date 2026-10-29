#!/bin/bash
COMPARISON_FILE="results/performance_comparison.txt"

echo "=== NETWORK PERFORMANCE COMPARISON REPORT ===" > $COMPARISON_FILE
echo "Generated: $(date)" >> $COMPARISON_FILE
echo "" >> $COMPARISON_FILE

get_throughput_bps() {
    local json_file=$1
    if [ -f "$json_file" ]; then
        jq -r '.end.sum_received.bits_per_second // empty' "$json_file"
    fi
}

BASELINE_BPS=$(get_throughput_bps "results/baseline_results.json")
TCP_OPT_BPS=$(get_throughput_bps "results/tcp_optimized_results.json")
FINAL_BPS=$(get_throughput_bps "results/comprehensive_results.json")

echo "=== Raw Throughput (bits per second) ===" >> $COMPARISON_FILE
echo "Baseline:        ${BASELINE_BPS:-N/A}" >> $COMPARISON_FILE
echo "TCP Optimized:   ${TCP_OPT_BPS:-N/A}" >> $COMPARISON_FILE
echo "Fully Optimized: ${FINAL_BPS:-N/A}" >> $COMPARISON_FILE
echo "" >> $COMPARISON_FILE

echo "=== Converted to Gbps ===" >> $COMPARISON_FILE
if [ -n "$BASELINE_BPS" ]; then
    echo "Baseline:        $(echo "scale=2; $BASELINE_BPS / 1000000000" | bc) Gbps" >> $COMPARISON_FILE
fi
if [ -n "$TCP_OPT_BPS" ]; then
    echo "TCP Optimized:   $(echo "scale=2; $TCP_OPT_BPS / 1000000000" | bc) Gbps" >> $COMPARISON_FILE
fi
if [ -n "$FINAL_BPS" ]; then
    echo "Fully Optimized: $(echo "scale=2; $FINAL_BPS / 1000000000" | bc) Gbps" >> $COMPARISON_FILE
fi
echo "" >> $COMPARISON_FILE

echo "=== PERFORMANCE IMPROVEMENT ANALYSIS ===" >> $COMPARISON_FILE
if [ -n "$BASELINE_BPS" ] && [ -n "$FINAL_BPS" ] && [ "$BASELINE_BPS" != "0" ]; then
    IMPROVEMENT=$(echo "scale=2; (($FINAL_BPS - $BASELINE_BPS) / $BASELINE_BPS) * 100" | bc)
    echo "Performance Improvement: ${IMPROVEMENT}%" >> $COMPARISON_FILE
else
    echo "Unable to calculate improvement percentage: missing or zero baseline JSON data." >> $COMPARISON_FILE
fi
echo "" >> $COMPARISON_FILE

echo "Performance comparison completed. Report saved to $COMPARISON_FILE"
