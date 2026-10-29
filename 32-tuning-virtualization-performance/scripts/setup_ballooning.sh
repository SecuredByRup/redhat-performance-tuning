#!/bin/bash

VM_NAME="performance-vm"

# Shutdown VM if running
sudo virsh shutdown $VM_NAME
sleep 10

# Add balloon device permanently to configuration
sudo virsh attach-device $VM_NAME --file balloon_config.xml --config

# Start VM
sudo virsh start $VM_NAME

echo "Memory ballooning enabled for $VM_NAME"
