#!/bin/bash

echo "=== System Performance Analysis ==="
echo "Timestamp: $(date)"
echo

echo "CPU Usage:"
mpstat 1 5

echo "Memory Usage:"
free -h
echo

echo "System Load:"
uptime
echo

echo "Top Processes by CPU:"
ps aux --sort=-%cpu | head -10
echo

echo "Top Processes by Memory:"
ps aux --sort=-%mem | head -10
echo

echo "Network Connections:"
echo "Active network connections: $(ss -tuln | wc -l)"
echo

echo "Disk I/O Statistics:"
iostat -x 1 3
