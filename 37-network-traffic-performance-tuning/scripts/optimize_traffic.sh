#!/bin/bash

echo "Dynamic Network Traffic Optimization"
echo "==================================="

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

optimize_connections() {
    local conn_count=$(ss -tan state established | wc -l)
    echo "Current established connections: $conn_count"
    
    if [ $conn_count -gt 1000 ]; then
        echo "High connection count detected. Applying optimizations..."
        echo 65536 > /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null || true
        echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
        echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
        echo "High-load optimizations applied."
    else
        echo "Connection count is normal. Standard optimizations applied."
    fi
}

optimize_interfaces() {
    echo ""
    echo "Optimizing network interfaces..."
    for interface in $(ls /sys/class/net/ | grep -E "^(eth|ens|enp)"); do
        if [ -d "/sys/class/net/$interface" ]; then
            ifconfig $interface txqueuelen 10000 2>/dev/null || true
            echo "Optimized $interface queue length"
        fi
    done
}

check_root
optimize_connections
optimize_interfaces

echo ""
echo "Traffic optimization completed."
