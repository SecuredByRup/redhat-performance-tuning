#!/bin/bash
echo "=== Performance Tuning Goals Demonstration ==="
measure_throughput() {
    echo "Measuring CPU throughput..."
    start_time=$(date +%s)
    for i in {1..10000}; do
        echo "scale=10; sqrt($i)" | bc -l > /dev/null 2>&1
    done
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    throughput=$((10000 / duration))
    echo "Completed 10,000 calculations in $duration seconds"
    echo "Throughput: $throughput calculations per second\n"
}
measure_response_time() {
    echo "Measuring file system response time..."
    for i in {1..5}; do
        start_time=$(date +%s.%N)
        dd if=/dev/zero of=/tmp/test_file_$i bs=1M count=10 2>/dev/null
        end_time=$(date +%s.%N)
        response_time=$(echo "$end_time - $start_time" | bc)
        echo "File creation $i response time: ${response_time}s"
        rm -f /tmp/test_file_$i
    done
    echo ""
}
measure_throughput
measure_response_time
