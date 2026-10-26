#!/bin/bash
LOGFILE="process_resources.log"
INTERVAL=5

echo "Timestamp,PID,User,CPU%,MEM%,VSZ,RSS,Command" > "$LOGFILE"
trap 'echo "Stopping tracker..."; exit 0' INT

for i in {1..6}; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
        echo "$TIMESTAMP,$line" | awk '{gsub(/ +/, ",", $0); print $1","$3","$2","$4","$5","$6","$7","$12}' >> "$LOGFILE"
    done
    sleep $INTERVAL
done
