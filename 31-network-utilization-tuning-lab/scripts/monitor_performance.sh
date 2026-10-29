#!/bin/bash
MONITOR_FILE="results/system_monitoring.txt"
DURATION=30
SERVER_IP="127.0.0.1"

echo "=== SYSTEM PERFORMANCE MONITORING ===" > $MONITOR_FILE
echo "Monitor Duration: ${DURATION} seconds" >> $MONITOR_FILE
date >> $MONITOR_FILE

(
    echo "=== CPU Usage ===" >> $MONITOR_FILE
    sar -u 5 $((DURATION/5)) >> $MONITOR_FILE
    echo "=== Network Interface Statistics ===" >> $MONITOR_FILE
    sar -n DEV 5 $((DURATION/5)) >> $MONITOR_FILE
    echo "=== Network Error Statistics ===" >> $MONITOR_FILE
    sar -n EDEV 5 $((DURATION/5)) >> $MONITOR_FILE
) &
MONITOR_PID=$!

iperf3 -c $SERVER_IP -p 5001 -t $DURATION -P 4 > /dev/null 2>&1

wait $MONITOR_PID
echo "Monitoring completed. Results saved to $MONITOR_FILE"
