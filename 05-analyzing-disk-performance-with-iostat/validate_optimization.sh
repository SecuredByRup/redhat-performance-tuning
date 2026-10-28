#!/bin/bash
# Performance Optimization Validation Script

VALIDATION_DIR="validation_$(date +%Y%m%d_%H%M%S)"
mkdir -p $VALIDATION_DIR

echo "Running post-optimization performance test..."
./check_schedulers.sh > $VALIDATION_DIR/current_schedulers.txt

iostat -x 1 30 > $VALIDATION_DIR/optimized_performance.log &
IOSTAT_PID=$!

./io_workload_generator.sh mixed > $VALIDATION_DIR/test_workload.log 2>&1
kill $IOSTAT_PID 2>/dev/null

echo "Validation completed! Report saved in $VALIDATION_DIR/"
