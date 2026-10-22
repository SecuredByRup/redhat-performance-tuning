#!/bin/bash

TEST_DURATION=60
RESULTS_DIR="$HOME/performance_results"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

echo "=== COMPREHENSIVE PERFORMANCE TEST SUITE ==="
echo "Test duration: $TEST_DURATION seconds"
echo "Results directory: $RESULTS_DIR"

mkdir -p $RESULTS_DIR

test_cpu() {
    echo "Running CPU performance test..."

    echo "CPU cores: $(nproc)" > $RESULTS_DIR/cpu_test_$TIMESTAMP.log
    echo "CPU model: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)" >> $RESULTS_DIR/cpu_test_$TIMESTAMP.log

    stress-ng --cpu $(nproc) --timeout ${TEST_DURATION}s --metrics-brief >> $RESULTS_DIR/cpu_test_$TIMESTAMP.log 2>&1 &
    STRESS_PID=$!

    for i in $(seq 1 $((TEST_DURATION/5))); do
        echo "Sample $i: $(date)" >> $RESULTS_DIR/cpu_monitoring_$TIMESTAMP.log
        sar -u 1 1 >> $RESULTS_DIR/cpu_monitoring_$TIMESTAMP.log
        sleep 4
    done

    wait $STRESS_PID
    echo "CPU test completed"
}

test_memory() {
    echo "Running memory performance test..."

    free -h > $RESULTS_DIR/memory_test_$TIMESTAMP.log

    MEMORY_SIZE=$(free -m | awk 'NR==2{printf "%.0f", $2*0.8}')
    echo "Testing with ${MEMORY_SIZE}MB memory allocation" >> $RESULTS_DIR/memory_test_$TIMESTAMP.log

    stress-ng --vm 2 --vm-bytes ${MEMORY_SIZE}M --timeout ${TEST_DURATION}s --metrics-brief >> $RESULTS_DIR/memory_test_$TIMESTAMP.log 2>&1 &
    STRESS_PID=$!

    for i in $(seq 1 $((TEST_DURATION/5))); do
        echo "Sample $i: $(date)" >> $RESULTS_DIR/memory_monitoring_$TIMESTAMP.log
        free -h >> $RESULTS_DIR/memory_monitoring_$TIMESTAMP.log
        sleep 4
    done

    wait $STRESS_PID
    echo "Memory test completed"
}

test_disk_io() {
    echo "Running disk I/O performance test..."

    TEST_DIR="$HOME/disk_test"
    mkdir -p $TEST_DIR

    echo "Write test:" > $RESULTS_DIR/disk_test_$TIMESTAMP.log
    dd if=/dev/zero of=$TEST_DIR/testfile bs=1M count=1024 oflag=direct 2>> $RESULTS_DIR/disk_test_$TIMESTAMP.log

    echo "Read test:" >> $RESULTS_DIR/disk_test_$TIMESTAMP.log
    dd if=$TEST_DIR/testfile of=/dev/null bs=1M iflag=direct 2>> $RESULTS_DIR/disk_test_$TIMESTAMP.log

    stress-ng --hdd 2 --hdd-bytes 1G --temp-path $TEST_DIR --timeout ${TEST_DURATION}s --metrics-brief >> $RESULTS_DIR/disk_test_$TIMESTAMP.log 2>&1 &
    STRESS_PID=$!

    for i in $(seq 1 $((TEST_DURATION/5))); do
        echo "Sample $i: $(date)" >> $RESULTS_DIR/disk_monitoring_$TIMESTAMP.log
        iostat -x 1 1 >> $RESULTS_DIR/disk_monitoring_$TIMESTAMP.log
        sleep 4
    done

    wait $STRESS_PID

    rm -rf $TEST_DIR
    echo "Disk I/O test completed"
}

echo "Starting performance test suite at $(date)"

test_cpu
echo ""
test_memory
echo ""
test_disk_io

echo ""
echo "=== PERFORMANCE TEST SUMMARY ==="
echo "All tests completed at $(date)"
echo "Results saved in: $RESULTS_DIR"
echo ""
echo "Test files created:"
ls -la $RESULTS_DIR/*$TIMESTAMP*

# Generate summary report
cat > $RESULTS_DIR/summary_report_$TIMESTAMP.txt << SUMMARY
PERFORMANCE TEST SUITE SUMMARY
Generated: $(date)
Test Duration per Component: $TEST_DURATION seconds

CPU TEST:
$(cat $RESULTS_DIR/cpu_test_$TIMESTAMP.log 2>/dev/null)

MEMORY TEST:
$(cat $RESULTS_DIR/memory_test_$TIMESTAMP.log 2>/dev/null)

DISK I/O TEST:
$(cat $RESULTS_DIR/disk_test_$TIMESTAMP.log 2>/dev/null)

END OF REPORT
SUMMARY

echo ""
echo "Summary report generated: $RESULTS_DIR/summary_report_$TIMESTAMP.txt"
cat $RESULTS_DIR/summary_report_$TIMESTAMP.txt
