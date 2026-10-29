#!/bin/bash

echo "=== Performance Tuning Results Comparison ==="
echo "Date: $(date)"
echo

echo "=== System Configuration Settings ==="
echo "  vm.swappiness: $(sysctl -n vm.swappiness)"
echo "  vm.dirty_ratio: $(sysctl -n vm.dirty_ratio)"
echo "  I/O Scheduler: $(cat /sys/block/sda/queue/scheduler 2>/dev/null || cat /sys/block/nvme0n1/queue/scheduler)"
echo

echo "=== PostgreSQL Key Parameters ==="
sudo -u postgres psql testdb -c "
    SELECT name, setting, unit 
    FROM pg_settings 
    WHERE name IN (
        'shared_buffers',
        'effective_cache_size',
        'work_mem',
        'maintenance_work_mem',
        'max_connections'
    );
"
