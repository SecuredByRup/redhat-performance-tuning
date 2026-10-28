#!/bin/bash
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

echo "Optimizing ring buffers for interface: $INTERFACE"

MAX_RX=$(ethtool -g $INTERFACE | awk '/Pre-set maximums/{f=1} f && /^RX:/{print $2; exit}')
MAX_TX=$(ethtool -g $INTERFACE | awk '/Pre-set maximums/{f=1} f && /^TX:/{print $2; exit}')

echo "Maximum RX ring buffer: $MAX_RX"
echo "Maximum TX ring buffer: $MAX_TX"

if [ -n "$MAX_RX" ] && [ "$MAX_RX" != "n/a" ]; then
    sudo ethtool -G $INTERFACE rx $MAX_RX
fi

if [ -n "$MAX_TX" ] && [ "$MAX_TX" != "n/a" ]; then
    sudo ethtool -G $INTERFACE tx $MAX_TX
fi

echo "New ring buffer settings:"
ethtool -g $INTERFACE
