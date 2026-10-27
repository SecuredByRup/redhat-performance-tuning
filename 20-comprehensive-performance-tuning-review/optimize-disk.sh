#!/bin/bash

echo "=== Disk I/O Performance Optimization ==="

# Optimize I/O scheduler
echo "Setting optimal I/O scheduler..."
for disk in /sys/block/sd*/queue/scheduler; do
    echo mq-deadline > $disk 2>/dev/null && echo "Set mq-deadline for $disk"
done

# Clean up temporary files
echo "Cleaning up temporary files..."
find /tmp -type f -atime +7 -delete 2>/dev/null
find /var/tmp -type f -atime +7 -delete 2>/dev/null

echo "Disk I/O optimization completed."
