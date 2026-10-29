#!/bin/bash
LOGFILE="system_performance.log"
DURATION=60

echo "=== System Performance Monitoring ===" | tee $LOGFILE
echo "Monitoring started at: $(date)" | tee -a $LOGFILE

log_metrics() {
    echo "=== Timestamp: $(date) ===" >> $LOGFILE
    echo "CPU Usage:" >> $LOGFILE
    top -bn1 | grep "Cpu(s)" >> $LOGFILE
    echo "Memory Usage:" >> $LOGFILE
    free -h >> $LOGFILE
    echo "Disk I/O:" >> $LOGFILE
    iostat -x 1 1 >> $LOGFILE 2>/dev/null || echo "iostat not available" >> $LOGFILE
    echo "Load Average:" >> $LOGFILE
    uptime >> $LOGFILE
    echo "----------------------------------------" >> $LOGFILE
}

for i in $(seq 1 6); do
    log_metrics
    echo "Sample $i/6 collected..."
    sleep 10
done
echo "Monitoring complete. Results saved to $LOGFILE"
