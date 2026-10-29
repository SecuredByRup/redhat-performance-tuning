#!/bin/bash
SERVER_IP="127.0.0.1"   # Using localhost for single-machine lab
RESULTS_TXT="results/comprehensive_results.txt"
RESULTS_JSON="results/comprehensive_results.json"

echo "=== COMPREHENSIVE NETWORK PERFORMANCE TEST ===" > $RESULTS_TXT
date >> $RESULTS_TXT

echo "=== Test 1: Single Stream TCP Throughput ===" >> $RESULTS_TXT
iperf3 -c $SERVER_IP -p 5001 -t 30 -i 5 >> $RESULTS_TXT

# Primary JSON capture used for automated comparison in Subtask 4.2
iperf3 -c $SERVER_IP -p 5001 -t 30 -J > $RESULTS_JSON

echo "=== Test 2: Multiple Parallel Streams (4 streams) ===" >> $RESULTS_TXT
iperf3 -c $SERVER_IP -p 5001 -t 30 -P 4 -i 5 >> $RESULTS_TXT

for window in 64K 128K 256K 512K 1M; do
    echo "=== Test 3: TCP with ${window} window size ===" >> $RESULTS_TXT
    iperf3 -c $SERVER_IP -p 5001 -t 15 -w $window >> $RESULTS_TXT
done

for rate in 100M 500M 1G; do
    echo "=== Test 4: UDP at ${rate} rate ===" >> $RESULTS_TXT
    iperf3 -c $SERVER_IP -p 5001 -u -b $rate -t 15 >> $RESULTS_TXT
done

echo "Comprehensive testing completed. Results saved to $RESULTS_TXT and $RESULTS_JSON"
