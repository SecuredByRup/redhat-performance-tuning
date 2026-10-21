#!/bin/bash

echo "=== Process Distribution Optimization ==="

# Function to demonstrate load balancing
demonstrate_load_balancing() {
    echo "Scenario 1: All processes on CPU 0 (Poor distribution)"
    
    # Start monitoring
    mpstat -P ALL 2 10 > unbalanced_load.log &
    MPSTAT_PID=$!
    
    # Run multiple processes on CPU 0 only
    for i in {1..4}; do
        taskset -c 0 stress --cpu 1 --timeout 8s &
    done
    
    wait $MPSTAT_PID
    
    echo "Results - Unbalanced Load:"
    grep "Average" unbalanced_load.log | head -5
    echo ""
    
    sleep 5
    
    echo "Scenario 2: Distributed processes (Good distribution)"
    
    # Start monitoring
    mpstat -P ALL 2 10 > balanced_load.log &
    MPSTAT_PID=$!
    
    # Distribute processes across available CPUs
    NUM_CPUS=$(nproc)
    for i in {1..4}; do
        CPU_ID=$(( (i-1) % NUM_CPUS ))
        taskset -c $CPU_ID stress --cpu 1 --timeout 8s &
    done
    
    wait $MPSTAT_PID
    
    echo "Results - Balanced Load:"
    grep "Average" balanced_load.log | head -5
    echo ""
}

demonstrate_load_balancing

# Analyze the difference
echo "=== Load Distribution Analysis ==="
echo "Unbalanced scenario - CPU utilization:"
awk '/Average/ && $3 ~ /^[0-9]+$/ {printf "CPU %s: %.1f%%\n", $3, $4+$6}' unbalanced_load.log

echo ""
echo "Balanced scenario - CPU utilization:"
awk '/Average/ && $3 ~ /^[0-9]+$/ {printf "CPU %s: %.1f%%\n", $3, $4+$6}' balanced_load.log
