#!/bin/bash

echo "=== Memory Performance Optimization ==="

# Clear system caches
echo "Clearing system caches..."
sync
echo 3 > /proc/sys/vm/drop_caches
echo "System caches cleared."

# Optimize swap usage
echo "Current swappiness value:"
cat /proc/sys/vm/swappiness

echo "Setting optimal swappiness value..."
echo 10 > /proc/sys/vm/swappiness
echo "vm.swappiness = 10" >> /etc/sysctl.conf

# Configure memory overcommit
echo "Configuring memory overcommit..."
echo 1 > /proc/sys/vm/overcommit_memory
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf

echo "Memory optimization completed."
