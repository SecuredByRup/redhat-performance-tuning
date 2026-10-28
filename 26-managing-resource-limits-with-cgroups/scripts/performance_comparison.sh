#!/bin/bash
echo "=== Performance Comparison: With vs Without cgroups ==="
echo

run_performance_test() {
    local test_name="$1"
    local use_cgroup="$2"
    echo "Running $test_name..."
    
    start_time=$(date +%s.%N)
    if [ "$use_cgroup" = "true" ]; then
        (echo "scale=2000; 4*a(1)" | bc -l > /dev/null) &
        test_pid=$!
        echo $test_pid | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs > /dev/null
        wait $test_pid
    else
        echo "scale=2000; 4*a(1)" | bc -l > /dev/null
    fi
    end_time=$(date +%s.%N)
    cpu_time=$(echo "$end_time - $start_time" | bc)
    echo "   Time: ${cpu_time}s"
}

run_performance_test "Test WITHOUT cgroups" "false"
run_performance_test "Test WITH cgroups" "true"
