#!/bin/bash

VM_NAME="performance-vm"
TEST_DURATION=60  # 1 minute test duration
LOG_DIR="/tmp/perf_logs"

mkdir -p $LOG_DIR

echo "Starting CPU performance test for $VM_NAME"

# Start monitoring in background using correct --cpu-total flag
sudo virsh domstats --cpu-total $VM_NAME > $LOG_DIR/cpu_before.log

# Run CPU stress test
echo "Running CPU stress test for ${TEST_DURATION} seconds..."
stress-ng --cpu 4 --timeout ${TEST_DURATION}s --metrics-brief &
STRESS_PID=$!

# Monitor during test
while kill -0 $STRESS_PID 2>/dev/null; do
    echo "$(date): CPU Usage:" >> $LOG_DIR/cpu_during.log
    sudo virsh domstats --cpu-total $VM_NAME >> $LOG_DIR/cpu_during.log
    top -bn1 | grep "Cpu(s)" >> $LOG_DIR/cpu_during.log
    sleep 10
done

# Final measurements
sudo virsh domstats --cpu-total $VM_NAME > $LOG_DIR/cpu_after.log

echo "CPU stress test completed. Logs saved in $LOG_DIR"
