#!/bin/bash

TEST_LOG="memory_performance_$(date +%Y%m%d_%H%M%S).log"

echo "Memory Performance Testing Suite"
echo "================================"
echo "Log file: $TEST_LOG"

log_system_state() {
    local test_name=$1
    echo "=== $test_name ===" >> $TEST_LOG
    echo "Timestamp: $(date)" >> $TEST_LOG
    echo "Memory Usage:" >> $TEST_LOG
    free -h >> $TEST_LOG
    echo "vmstat snapshot:" >> $TEST_LOG
    vmstat 1 1 >> $TEST_LOG
    echo "Swap activity:" >> $TEST_LOG
    cat /proc/vmstat | grep -E "(pswpin|pswpout)" >> $TEST_LOG
    echo "" >> $TEST_LOG
}

echo "Test 1: Baseline measurement"
log_system_state "Baseline"

echo "Test 2: Memory allocation test"
if command -v stress-ng >/dev/null 2>&1; then
    stress-ng --vm 2 --vm-bytes 256M --timeout 30s &
    STRESS_PID=$!
    for i in {1..6}; do
        echo "Sample $i..."
        sleep 5
        log_system_state "Stress Test - Sample $i"
    done
    wait $STRESS_PID
else
    echo "stress-ng not available, using alternative method (dd)"
    dd if=/dev/zero of=/tmp/memory_test bs=1M count=512 &
    DD_PID=$!
    for i in {1..6}; do
        echo "Sample $i..."
        sleep 5
        log_system_state "Memory Pressure - Sample $i"
    done
    kill $DD_PID 2>/dev/null
    rm -f /tmp/memory_test
fi

echo "Test 3: Post-test measurement"
sleep 10
log_system_state "Post-test"

echo "Performance testing complete!"
echo "Results saved to: $TEST_LOG"
