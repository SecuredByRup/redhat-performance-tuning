#!/bin/bash
# Baseline CPU & Memory Monitoring Script
LOG_DIR="monitoring_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/cpu_${TIMESTAMP}.log"

echo "Starting baseline monitoring for 60 seconds..."
echo "Timestamp,CPU_Usage_Percent,Mem_Used_MB,Mem_Total_MB" > "$LOG_FILE"

for i in {1..12}; do
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 15 - $8}') # or standard idle parse
    MEM_INFO=$(free -m | awk 'NR==2{printf "%s,%s", $3, $2}')
    
    # Fallback safe CPU parse from top
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    CPU_USED=$(echo "100 - $CPU_IDLE" | bc)
    
    echo "$CURRENT_TIME,$CPU_USED,$MEM_INFO" >> "$LOG_FILE"
    sleep 5
done

echo "Baseline monitoring completed. Check $LOG_FILE for results."
