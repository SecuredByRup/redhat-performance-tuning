#!/bin/bash
echo "=== CPU GOVERNOR CONFIGURATION ==="
if [ ! -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    echo "cpufreq interface not available in this virtualized environment. Skipping."
    exit 0
fi
sudo cpupower frequency-set -g performance
cpupower frequency-info | grep "current policy"
