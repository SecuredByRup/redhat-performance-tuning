#!/bin/bash

ARCHIVE_DIR="/var/log/pcp/pmlogger/ip-172-31-10-61.ec2.internal"
LATEST_ARCHIVE=$(ls -t "$ARCHIVE_DIR"/*.index 2>/dev/null | head -1 | sed 's/\.index$//')

if [ -z "$LATEST_ARCHIVE" ]; then
    echo "No archives found in $ARCHIVE_DIR. Please ensure pmlogger has collected data."
    exit 1
fi

echo "Analyzing trends from: $LATEST_ARCHIVE"
echo "======================================"

# CPU trend analysis
echo "CPU Usage Trends:"
pmdumptext -a "$LATEST_ARCHIVE" -t 60 kernel.all.cpu.user kernel.all.cpu.sys | \
    awk 'NR>1 {user+=$2; sys+=$3; count++} END {
        if(count>0) printf "Average CPU User: %.2f%%, System: %.2f%%\n", user/count, sys/count
    }'

# Load average trends
echo "Load Average Trends:"
pmdumptext -a "$LATEST_ARCHIVE" -t 60 kernel.all.load | \
    awk 'NR>1 {load+=$2; count++} END {
        if(count>0) printf "Average Load: %.2f\n", load/count
    }'

echo "Trend analysis complete!"
