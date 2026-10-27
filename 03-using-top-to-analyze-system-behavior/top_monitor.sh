#!/bin/bash
echo "Starting comprehensive system monitoring..."

capture_top() {
    local duration=$1
    local output_file=$2
    echo "Capturing top output for $duration seconds..."
    timeout $duration top -b -n $((duration/2)) > $output_file
    echo "Output saved to $output_file"
}

analyze_top() {
    local input_file=$1
    echo "Analysis of $input_file:"
    echo "========================"
    echo "Load Average Trends:"
    grep "load average" $input_file | awk '{print $12, $13, $14}'
    echo ""
    echo "Top CPU Consumers:"
    grep -A 20 "PID USER" $input_file | grep -v "PID USER" | head -10
    echo ""
    echo "Memory Usage Patterns:"
    grep "MiB Mem" $input_file 2>/dev/null || grep "Mem:" $input_file
    echo ""
}

capture_top 10 "system_performance.log"
analyze_top "system_performance.log"
