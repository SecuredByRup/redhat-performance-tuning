#!/bin/bash
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "=== INTERFACE & BUFFER BASELINE ===" > results/baseline_config.txt
echo "Primary Interface: $INTERFACE" >> results/baseline_config.txt
ip addr show $INTERFACE >> results/baseline_config.txt
echo "" >> results/baseline_config.txt

echo "--- Current sysctl Buffer Values ---" >> results/baseline_config.txt
sysctl net.core.rmem_max >> results/baseline_config.txt
sysctl net.core.wmem_max >> results/baseline_config.txt
sysctl net.core.rmem_default >> results/baseline_config.txt
sysctl net.core.wmem_default >> results/baseline_config.txt
sysctl net.ipv4.tcp_rmem >> results/baseline_config.txt
sysctl net.ipv4.tcp_wmem >> results/baseline_config.txt
echo "" >> results/baseline_config.txt

echo "--- Ethtool Ring Buffers ---" >> results/baseline_config.txt
ethtool -g $INTERFACE >> results/baseline_config.txt
echo "Baseline configuration capture complete."
