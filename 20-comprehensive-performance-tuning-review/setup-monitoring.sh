#!/bin/bash

echo "=== Setting up Ongoing Performance Monitoring ==="

mkdir -p /opt/performance-monitoring/logs
mkdir -p /opt/performance-monitoring/reports

cat > /opt/performance-monitoring/daily-monitor.sh << 'DAILY_EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
LOGDIR="/opt/performance-monitoring/logs"
{
    echo "=== Daily Performance Report - $(date) ==="
    uptime
    free -h
    df -h
} > ${LOGDIR}/daily-report-${DATE}.txt
DAILY_EOF

chmod +x /opt/performance-monitoring/daily-monitor.sh

# Set up cron jobs safely
(crontab -l 2>/dev/null; echo "0 6 * * * /opt/performance-monitoring/daily-monitor.sh") | crontab -

echo "Automated monitoring setup completed successfully."
