#!/bin/bash

# Performance Dashboard Generator
HOSTS=("localhost" "target-1" "target-2")
OUTPUT_DIR="./pcp_reports"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

echo "Generating performance dashboard for $(date)"
echo "============================================="

for host in "${HOSTS[@]}"; do
    echo "Processing $host..."
    
    cat > "$OUTPUT_DIR/${host}_summary_${DATE}.txt" << EOL
Performance Summary for $host - $(date)
=====================================

CPU Information:
$(pminfo -h $host -f hinv.ncpu 2>/dev/null || echo "N/A")

Memory Information:
$(pminfo -h $host -f mem.physmem 2>/dev/null || echo "N/A")

Current Load:
$(pminfo -h $host -f kernel.all.load 2>/dev/null || echo "N/A")

Current CPU Usage:
$(pminfo -h $host -f kernel.all.cpu.user kernel.all.cpu.sys 2>/dev/null || echo "N/A")
EOL

    echo "Report generated: $OUTPUT_DIR/${host}_summary_${DATE}.txt"
done

echo "Dashboard generation complete! Reports saved in $OUTPUT_DIR"
