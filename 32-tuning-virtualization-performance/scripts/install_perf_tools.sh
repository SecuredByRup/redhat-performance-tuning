#!/bin/bash

echo "Installing performance testing and monitoring tools..."

# Enable EPEL repository for advanced tools like stress-ng, fio, etc. if not already enabled
sudo dnf install -y epel-release

# Install testing & benchmarking suites
sudo dnf install -y stress-ng sysbench iperf3 fio htop iotop sysstat

echo "Performance tools installation completed"
