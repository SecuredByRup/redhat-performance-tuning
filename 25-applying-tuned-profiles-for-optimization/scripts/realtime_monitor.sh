#!/bin/bash

PROFILE=$1
DURATION=${2:-30}

if [ -z "$PROFILE" ]; then
    echo "Usage: $0 <profile_name> [duration_in_seconds]"
    exit 1
fi

echo "Real-time monitoring for profile: $PROFILE"
echo "Duration: $DURATION seconds"
echo "Press Ctrl+C to stop early"

# Apply the specified profile
sudo tuned-adm profile $PROFILE

# Monitor for specified duration
for ((i=1; i<=DURATION; i++)); do
    clear
    echo "=== Real-time Performance Monitor ==="
    echo "Profile: $(tuned-adm active | cut -d: -f2 | xargs)"
    echo "Time: $(date)"
    echo "Monitoring: $i/$DURATION seconds"
    echo ""
    
    echo "=== CPU Information ==="
    if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
        echo "Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
        echo "Frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 'N/A') kHz"
    else
        echo "CPU frequency scaling not available in virtual guest"
    fi
    echo ""
    
    echo "=== Load and CPU Usage ==="
    uptime
    top -bn1 | grep "Cpu(s)" | head -1
    echo ""
    
    echo "=== Memory Usage ==="
    free -h | grep -E "(Mem|Swap)"
    echo ""
    
    echo "=== I/O Information ==="
    disk_found=false
    for disk in sda vda nvme0n1; do
        if [ -f /sys/block/$disk/queue/scheduler ]; then
            echo "Scheduler: $(cat /sys/block/$disk/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')"
            disk_found=true
            break
        fi
    done
    if [ "$disk_found" = false ]; then
        echo "Scheduler: N/A (Virtual Guest Storage)"
    fi
    
    sleep 1
done
