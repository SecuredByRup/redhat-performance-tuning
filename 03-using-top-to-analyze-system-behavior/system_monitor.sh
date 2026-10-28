#!/bin/bash
echo "System Performance Analysis"
echo "=========================="
echo "Date: $(date)"
echo ""
echo "CPU Information:"
echo "Cores: $(nproc)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""
echo "Memory Information:"
free -h
echo ""
echo "Top 10 CPU Consuming Processes:"
ps aux --sort=-%cpu | head -11
echo ""
echo "Top 10 Memory Consuming Processes:"
ps aux --sort=-%mem | head -11
echo ""
echo "Disk Usage:"
df -h
echo ""
echo "Active Network Connections:"
netstat -tuln | wc -l
