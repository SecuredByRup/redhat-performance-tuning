#!/bin/bash
# Database I/O Tuning Script (Persistent via rc.local / systemd)
DB_DISK="nvme0n1"

# Set I/O scheduler to deadline (or fallback to mq-deadline)
echo deadline > /sys/block/$DB_DISK/queue/scheduler 2>/dev/null || echo mq-deadline > /sys/block/$DB_DISK/queue/scheduler

# Configure deadline scheduler parameters for database workloads
echo 1 > /sys/block/$DB_DISK/queue/iosched/front_merges
echo 150 > /sys/block/$DB_DISK/queue/iosched/read_expire
echo 1500 > /sys/block/$DB_DISK/queue/iosched/write_expire
echo 6 > /sys/block/$DB_DISK/queue/iosched/writes_starved

# Set queue depth
echo 32 > /sys/block/$DB_DISK/queue/nr_requests
