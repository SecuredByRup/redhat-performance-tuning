#!/bin/bash

echo "=== Performance Comparison ==="
echo "Comparing baseline vs optimized performance"
echo

echo "Network Buffer Sizes:"
sysctl net.core.rmem_max net.core.wmem_max net.core.netdev_max_backlog

echo
echo "Storage I/O Settings:"
echo "Current I/O Scheduler: $(cat /sys/block/nvme0n1/queue/scheduler)"
echo "Read-ahead: $(cat /sys/block/nvme0n1/queue/read_ahead_kb) KB"
echo "Request Queue Depth: $(cat /sys/block/nvme0n1/queue/nr_requests)"

echo
echo "Virtual Memory Settings:"
sysctl vm.dirty_ratio vm.dirty_background_ratio vm.swappiness
