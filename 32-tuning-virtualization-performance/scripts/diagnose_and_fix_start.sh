#!/bin/bash
VM_NAME="performance-vm"
XML_PATH="/tmp/${VM_NAME}.xml"

echo "=== 1. Checking recent libvirt error log ==="
sudo tail -n 25 /var/log/libvirt/qemu/${VM_NAME}.log 2>/dev/null || echo "No specific VM log found yet."

echo -e "\n=== 2. Attempting start to capture live error ==="
sudo virsh start $VM_NAME

echo -e "\n=== 3. Switching domain type to 'qemu' (software emulation fallback) ==="
sudo virsh dumpxml $VM_NAME > $XML_PATH
sed -i "s/type='kvm'/type='qemu'/g" $XML_PATH
sudo virsh define $XML_PATH
rm -f $XML_PATH

echo -e "\n=== 4. Retrying start with QEMU emulation ==="
sudo virsh start $VM_NAME

echo -e "\n=== 5. Final VM Status ==="
sudo virsh list --all
