#!/bin/bash
echo "=== cgroup Troubleshooting Guide ==="
echo

echo "1. Checking cgroups v2 mount:"
if mount | grep -q "cgroup2"; then
    echo "   ✓ cgroups v2 is mounted"
else
    echo "   ✗ cgroups v2 not found"
fi
echo

echo "2. Checking available controllers:"
if [ -f "/sys/fs/cgroup/cgroup.controllers" ]; then
    controllers=$(cat /sys/fs/cgroup/cgroup.controllers)
    echo "   Available: $controllers"
fi
echo

echo "3. Checking permissions:"
if [ -w "/sys/fs/cgroup" ]; then
    echo "   ✓ Write access to cgroup filesystem"
else
    echo "   ✗ No write access - run with sudo"
fi
echo "=== End Troubleshooting ==="
