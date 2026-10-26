#!/bin/bash

echo "Generating CPU load..."
stress-ng --cpu 2 --timeout 60s &

echo "Generating memory load..."
stress-ng --vm 1 --vm-bytes 512M --timeout 60s &

echo "Generating disk I/O load..."
dd if=/dev/zero of=/tmp/testfile bs=1M count=1000 &

echo "Load generation started..."
wait
echo "Load generation completed."
rm -f /tmp/testfile
