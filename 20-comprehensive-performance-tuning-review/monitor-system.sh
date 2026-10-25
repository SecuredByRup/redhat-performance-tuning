#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="."

echo "Starting comprehensive system monitoring at $(date)"

# CPU monitoring with top
top -b -n 5 -d 2 > ${LOGDIR}/cpu-data/top-baseline-${TIMESTAMP}.txt &

# Memory and CPU with sar (5-second intervals, 12 samples)
sar -u -r 5 12 > ${LOGDIR}/cpu-data/sar-cpu-memory-${TIMESTAMP}.txt &

# Disk I/O monitoring
iostat -x 5 12 > ${LOGDIR}/disk-data/iostat-baseline-${TIMESTAMP}.txt &

# Network monitoring
sar -n DEV 5 12 > ${LOGDIR}/network-data/sar-network-${TIMESTAMP}.txt &

echo "Monitoring started. Log files created with timestamp: ${TIMESTAMP}"
