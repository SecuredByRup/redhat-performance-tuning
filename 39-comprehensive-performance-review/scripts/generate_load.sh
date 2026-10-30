#!/bin/bash

echo "Generating combined CPU and I/O load for 120 seconds..."

# CPU load: two background workers computing prime factors in a loop
stress_cpu() {
    local end_time=$(( $(date +%s) + 120 ))
    while [ "$(date +%s)" -lt "$end_time" ]; do
        for i in $(seq 1 2000); do
            factor "$i" > /dev/null 2>&1
        done
    done
}
stress_cpu &
stress_cpu &

# I/O load: write and read files under /tmp
mkdir -p /tmp/io_test
(
    for i in 1 2 3; do
        dd if=/dev/zero of=/tmp/io_test/testfile_${i}.dat bs=1M count=80 2>/dev/null
    done
    sleep 30
    for i in 1 2 3; do
        dd if=/tmp/io_test/testfile_${i}.dat of=/dev/null bs=1M 2>/dev/null
    done
    rm -f /tmp/io_test/testfile_*.dat
) &

wait
echo "Load generation complete."
