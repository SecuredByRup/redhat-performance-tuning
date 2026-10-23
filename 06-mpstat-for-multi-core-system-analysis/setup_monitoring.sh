#!/bin/bash

echo "=== Setting up Automated CPU Monitoring ==="

MONITOR_DIR="$HOME/cpu_monitoring"
mkdir -p "$MONITOR_DIR"
cd "$MONITOR_DIR"

cat > continuous_monitor.sh << 'MONITOR_EOF'
#!/bin/bash
LOG_DIR="$HOME/cpu_monitoring/logs"
mkdir -p "$LOG_DIR"
DATE_STR=$(date +%Y%m%d)
LOG_FILE="$LOG_DIR/cpu_monitor_$DATE_STR.log"

log_with_timestamp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_with_timestamp "CPU monitoring started"

while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CPU Statistics:" >> "$LOG_FILE"
    mpstat -P ALL 1 1 | grep -E "(Average:|CPU)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    sleep 300
done
MONITOR_EOF

chmod +x continuous_monitor.sh

echo "Monitoring setup completed in $MONITOR_DIR!"
