#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges. Re-run with sudo."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BASE_DIR}/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backing up current tunables to $BACKUP_DIR"
cat /proc/sys/vm/swappiness > "$BACKUP_DIR/swappiness.bak"
cat /proc/sys/vm/dirty_ratio > "$BACKUP_DIR/dirty_ratio.bak"
cat /proc/sys/vm/dirty_background_ratio > "$BACKUP_DIR/dirty_background_ratio.bak"
cat /proc/sys/net/core/rmem_max > "$BACKUP_DIR/rmem_max.bak"
cat /proc/sys/net/core/wmem_max > "$BACKUP_DIR/wmem_max.bak"

echo "Applying memory tuning..."
echo 10 > /proc/sys/vm/swappiness
echo 15 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio

echo "Applying I/O scheduler tuning..."
for disk in $(lsblk -d -n -o NAME | grep -E '^[a-z]+$'); do
    if [ -f "/sys/block/$disk/queue/scheduler" ]; then
        rotational=$(cat "/sys/block/$disk/queue/rotational")
        if [ "$rotational" = "0" ]; then
            echo none > "/sys/block/$disk/queue/scheduler" 2>/dev/null || \
                echo mq-deadline > "/sys/block/$disk/queue/scheduler" 2>/dev/null
        else
            echo mq-deadline > "/sys/block/$disk/queue/scheduler" 2>/dev/null || \
                echo cfq > "/sys/block/$disk/queue/scheduler" 2>/dev/null
        fi
    fi
done

echo "Applying network buffer tuning..."
echo 16777216 > /proc/sys/net/core/rmem_max
echo 16777216 > /proc/sys/net/core/wmem_max
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling

cat > /etc/sysctl.d/99-performance-tuning.conf << SYSCTL_EOF
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_window_scaling = 1
SYSCTL_EOF

echo "Persistent configuration written to /etc/sysctl.d/99-performance-tuning.conf"
