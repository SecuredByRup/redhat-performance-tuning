#!/bin/bash

echo "Generating system load for testing..."

# Install stress-ng if not available
if ! command -v stress-ng >/dev/null 2>&1; then
    sudo yum install -y stress-ng || sudo apt install -y stress-ng
fi

# CPU load
stress-ng --cpu 2 --timeout 30s &

# Memory load  
stress-ng --vm 1 --vm-bytes 256M --timeout 30s &

# Disk I/O load
dd if=/dev/zero of=/tmp/testfile bs=1M count=100 conv=fdatasync 2>/dev/null

wait
rm -f /tmp/testfile
echo "Load generation complete!"
