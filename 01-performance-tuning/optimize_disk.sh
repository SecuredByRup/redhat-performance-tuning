#!/bin/bash
echo "=== DISK I/O OPTIMIZATION ==="
DISKS=$(lsblk -d -n -o NAME | grep -E "^sd|^nvme|^vd")
for DISK in $DISKS; do
    if [ -f /sys/block/$DISK/queue/read_ahead_kb ]; then
        echo "Setting read-ahead for $DISK to 128KB"
        echo 128 | sudo tee /sys/block/$DISK/queue/read_ahead_kb
    fi
done
echo "Disk optimization complete"
