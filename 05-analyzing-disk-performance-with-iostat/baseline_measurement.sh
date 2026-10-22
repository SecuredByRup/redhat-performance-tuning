#!/bin/bash
# Baseline Performance Measurement Script

BASELINE_DIR="baseline_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BASELINE_DIR

echo "Establishing performance baseline..."
echo "Measurement directory: $BASELINE_DIR"

# Collect system information
echo "System Information:" > $BASELINE_DIR/system_info.txt
uname -a >> $BASELINE_DIR/system_info.txt
cat /proc/cpuinfo | grep "model name" | head -1 >> $BASELINE_DIR/system_info.txt
free -h >> $BASELINE_DIR/system_info.txt
df -h >> $BASELINE_DIR/system_info.txt

# Collect idle performance metrics
echo "Collecting idle performance metrics..."
iostat -x 1 30 > $BASELINE_DIR/idle_performance.log &
IOSTAT_PID=$!

sleep 30
kill $IOSTAT_PID 2>/dev/null

# Collect loaded performance metrics
echo "Collecting loaded performance metrics..."
./io_workload_generator.sh mixed &
WORKLOAD_PID=$!

iostat -x 1 60 > $BASELINE_DIR/loaded_performance.log &
IOSTAT_PID=$!

sleep 60
kill $IOSTAT_PID 2>/dev/null
kill $WORKLOAD_PID 2>/dev/null

echo "Baseline measurement completed in: $BASELINE_DIR"
ls -la $BASELINE_DIR/
