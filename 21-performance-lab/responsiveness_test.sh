#!/bin/bash
echo "=== System Responsiveness Testing ==="
total_time=0
for i in {1..5}; do
    start_time=$(date +%s.%N)
    touch /tmp/response_test_$i && rm /tmp/response_test_$i
    end_time=$(date +%s.%N)
    iteration_time=$(echo "$end_time - $start_time" | bc)
    total_time=$(echo "$total_time + $iteration_time" | bc)
done
echo "Average filesystem touch/remove response time: $(echo "scale=6; $total_time / 5" | bc)s"
