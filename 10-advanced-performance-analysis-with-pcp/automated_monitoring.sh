#!/bin/bash

# Automated PCP Monitoring Daemon / Script
HOSTS=("localhost" "target-1" "target-2")
LOG_FILE="/var/log/pcp_monitoring.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Starting automated PCP cluster health check..." | sudo tee -a "$LOG_FILE" >/dev/null

for host in "${HOSTS[@]}"; do
    # Check if host is responding and extract clean load value
    if pminfo -h "$host" kernel.all.load >/dev/null 2>&1; then
        STATUS="ONLINE"
        # Extract the value cleanly after the '=' sign or last field
        LOAD=$(pminfo -h "$host" -f kernel.all.load 2>/dev/null | grep value | head -1 | awk -F '=' '{print $2}')
        [ -z "$LOAD" ] && LOAD=$(pminfo -h "$host" kernel.all.load | awk '{print $NF}')
    else
        STATUS="OFFLINE"
        LOAD="N/A"
    fi
    
    LOG_MSG="[$TIMESTAMP] Host: $host | Status: $STATUS | 1-min Load: $LOAD"
    echo "$LOG_MSG" | sudo tee -a "$LOG_FILE"
done

echo "[$TIMESTAMP] Automated health check completed." | sudo tee -a "$LOG_FILE" >/dev/null
