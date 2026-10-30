#!/bin/bash

echo "CURRENT SYSTEM TUNABLE VALUES"
echo "==============================="
echo "vm.swappiness: $(cat /proc/sys/vm/swappiness)"
echo "vm.dirty_ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "vm.dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo "net.core.rmem_max: $(cat /proc/sys/net/core/rmem_max)"
echo "net.core.wmem_max: $(cat /proc/sys/net/core/wmem_max)"
echo "net.ipv4.tcp_window_scaling: $(cat /proc/sys/net/ipv4/tcp_window_scaling)"

for disk in $(lsblk -d -n -o NAME 2>/dev/null | grep -E '^[a-z]+$'); do
    if [ -f "/sys/block/$disk/queue/scheduler" ]; then
        echo "I/O scheduler for $disk: $(cat /sys/block/$disk/queue/scheduler)"
    fi
done
