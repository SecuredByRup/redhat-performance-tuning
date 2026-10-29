#!/bin/bash
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

echo "Current coalescing settings:"
ethtool -c $INTERFACE

sudo ethtool -C $INTERFACE adaptive-rx on adaptive-tx on 2>/dev/null && echo "Adaptive coalescing: enabled" || echo "Adaptive coalescing: not supported"
sudo ethtool -C $INTERFACE rx-usecs 50 2>/dev/null && echo "RX interrupt delay: 50 usecs" || echo "RX interrupt delay: not configurable"
sudo ethtool -C $INTERFACE tx-usecs 50 2>/dev/null && echo "TX interrupt delay: 50 usecs" || echo "TX interrupt delay: not configurable"

echo "New coalescing settings:"
ethtool -c $INTERFACE
