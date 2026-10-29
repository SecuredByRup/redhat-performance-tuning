#!/bin/bash
echo "Starting Disk I/O stress... Press Ctrl+C to stop."
for i in {1..3}; do
    (while true; do
        dd if=/dev/zero of=/tmp/disktest_$i bs=1M count=100 2>/dev/null
        rm -f /tmp/disktest_$i
    done) &
done
trap 'kill $(jobs -p); echo "Stopped Disk I/O stress."; exit' INT
wait
