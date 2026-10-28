#!/bin/bash

echo "=== Historical CPU Performance Analysis ==="

# Function to generate sample data if SAR is not available
generate_sample_data() {
    echo "Collecting 5 minutes of sample data..."
    mpstat -P ALL 2 10 > sample_historical.log
    
    echo "=== Sample Data Analysis ==="
    echo "Average utilization over sampling period:"
    grep "Average" sample_historical.log
}

# Check if sar data is available
if [ -d "/var/log/sysstat" ] || [ -d "/var/log/sa" ]; then
    echo "System Activity Reporter (SAR) data found."
    
    SAR_DIR="/var/log/sysstat"
    [ ! -d "$SAR_DIR" ] && SAR_DIR="/var/log/sa"
    
    LATEST_FILE=$(ls -t$SAR_DIR/sa[0-9]* 2>/dev/null | head -1)
    
    if [ -n "$LATEST_FILE" ]; then
        echo "Analyzing data from: $LATEST_FILE"
        echo ""
        
        echo "=== CPU Utilization Summary ==="
        sar -u -f "$LATEST_FILE" | tail -20
        echo ""
    else
        echo "No SAR data files found. Generating sample data..."
        generate_sample_data
    fi
else
    echo "SAR not configured. Generating sample data..."
    generate_sample_data
fi
