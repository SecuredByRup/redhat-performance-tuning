#!/bin/bash

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
PROFILE_NAME=$1
OUTPUT_DIR="tuned_performance_data"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

LOGFILE="$OUTPUT_DIR/${PROFILE_NAME}_${TIMESTAMP}.log"

echo "=== Performance Monitoring for Profile: $PROFILE_NAME ===" > $LOGFILE
echo "Timestamp: $(date)" >> $LOGFILE
echo "" >> $LOGFILE

# System information
echo "=== System Information ===" >> $LOGFILE
uname -a >> $LOGFILE
echo "" >> $LOGFILE

# CPU information
echo "=== CPU Information ===" >> $LOGFILE
lscpu >> $LOGFILE
echo "" >> $LOGFILE

# Current tuned profile
echo "=== Current Tuned Profile ===" >> $LOGFILE
tuned-adm active >> $LOGFILE
echo "" >> $LOGFILE

# CPU governor (safely handled if missing)
echo "=== CPU Governor ===" >> $LOGFILE
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >> $LOGFILE
else
    echo "CPU frequency scaling not available in virtual guest" >> $LOGFILE
fi
echo "" >> $LOGFILE

# I/O scheduler
echo "=== I/O Scheduler ===" >> $LOGFILE
for disk in sda vda nvme0n1; do
    if [ -f /sys/block/$disk/queue/scheduler ]; then
        cat /sys/block/$disk/queue/scheduler >> $LOGFILE
        break
    fi
done
echo "" >> $LOGFILE

# Key kernel parameters
echo "=== Key Kernel Parameters ===" >> $LOGFILE
echo "vm.swappiness: $(sysctl -n vm.swappiness)" >> $LOGFILE
echo "net.core.rmem_max: $(sysctl -n net.core.rmem_max)" >> $LOGFILE
echo "" >> $LOGFILE

# Memory information
echo "=== Memory Information ===" >> $LOGFILE
free -h >> $LOGFILE
echo "" >> $LOGFILE

# Load average
echo "=== Load Average ===" >> $LOGFILE
uptime >> $LOGFILE
echo "" >> $LOGFILE

echo "Performance data collected in: $LOGFILE"
