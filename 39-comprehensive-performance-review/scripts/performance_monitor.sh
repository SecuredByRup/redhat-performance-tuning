#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MONITOR_DIR="${BASE_DIR}/monitoring/${TIMESTAMP}"
DURATION=120   # seconds
SAMPLE_INTERVAL=2
SAMPLES=$((DURATION / SAMPLE_INTERVAL))

mkdir -p "$MONITOR_DIR"
cd "$MONITOR_DIR" || exit 1

echo "Starting monitoring run: $TIMESTAMP"
echo "Duration: ${DURATION}s, samples:${SAMPLES}"

top -b -d "$SAMPLE_INTERVAL" -n "$SAMPLES" > top_output.txt &
TOP_PID=$!

iostat -x "$SAMPLE_INTERVAL" "$SAMPLES" > iostat_output.txt &
IOSTAT_PID=$!

sar -u -r -d "$SAMPLE_INTERVAL" "$SAMPLES" > sar_output.txt &
SAR_PID=$!

vmstat "$SAMPLE_INTERVAL" "$SAMPLES" > vmstat_output.txt &
VMSTAT_PID=$!

: > memory_tracking.txt
remaining=$DURATION
while [ "$remaining" -gt 0 ]; do
    echo "$(date +\%s)$(free -m | awk '/Mem:/ {print $2, $3}')" >> memory_tracking.txt
    sleep "$SAMPLE_INTERVAL"
    remaining=$((remaining - SAMPLE_INTERVAL))
done &
MEM_PID=$!

echo "$TOP_PID $IOSTAT_PID$SAR_PID $VMSTAT_PID$MEM_PID" > monitor_pids.txt

wait $TOP_PID $IOSTAT_PID$SAR_PID $VMSTAT_PID$MEM_PID 2>/dev/null

echo "Monitoring complete. Data stored in: $MONITOR_DIR"
echo "$MONITOR_DIR" > "${BASE_DIR}/monitoring/LATEST"
