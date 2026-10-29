#!/bin/bash
echo "=== Buffer Size Calculation ==="

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
SPEED=$(ethtool $INTERFACE 2>/dev/null | grep "Speed:" | awk '{print $2}' | sed 's/Mb\/s//')

if [ -z "$SPEED" ] || [ "$SPEED" = "Unknown!" ]; then
    SPEED=1000  # Default to 1Gbps if unable to detect
fi

echo "Interface: $INTERFACE"
echo "Speed: ${SPEED}Mbps"

GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
RTT=$(ping -c 5 $GATEWAY 2>/dev/null | tail -1 | awk -F'/' '{print $5}' | cut -d'.' -f1)

if [ -z "$RTT" ]; then
    RTT=1
fi

echo "Estimated RTT: ${RTT}ms"

# BDP (bytes) = (Speed_Mbps * RTT_ms * 1000) / 8
BDP=$(echo "scale=0; ($SPEED * $RTT * 1000) / 8" | bc -l 2>/dev/null || echo $((SPEED * RTT * 125)))
echo "Calculated BDP: ${BDP} bytes"

RECOMMENDED_BUFFER=$((BDP * 2))
echo "Recommended buffer size: ${RECOMMENDED_BUFFER} bytes"

if [ $RECOMMENDED_BUFFER -lt 65536 ]; then
    RECOMMENDED_BUFFER=65536
fi

if [ $RECOMMENDED_BUFFER -gt 33554432 ]; then
    RECOMMENDED_BUFFER=33554432
fi

echo "Final recommended buffer size: ${RECOMMENDED_BUFFER} bytes"
