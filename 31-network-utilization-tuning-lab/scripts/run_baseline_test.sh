#!/bin/bash
mkdir -p ./results
SERVER_IP="127.0.0.1"   # Use localhost since it's a single machine

echo "=== BASELINE PERFORMANCE TEST ===" > results/baseline_results.txt
date >> results/baseline_results.txt

echo "TCP Throughput Test:" >> results/baseline_results.txt
iperf3 -c $SERVER_IP -p 5001 -t 30 >> results/baseline_results.txt

# JSON output for automated comparison later in Task 4
iperf3 -c $SERVER_IP -p 5001 -t 30 -J > results/baseline_results.json

echo "UDP Throughput Test:" >> results/baseline_results.txt
iperf3 -c $SERVER_IP -p 5001 -u -b 1G -t 30 >> results/baseline_results.txt

echo "Latency Test:" >> results/baseline_results.txt
ping -c 100 $SERVER_IP >> results/baseline_results.txt

echo "Baseline tests completed successfully."
