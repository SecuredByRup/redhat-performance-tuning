#!/bin/bash

VM_NAME="performance-vm"
XML_PATH="/tmp/${VM_NAME}.xml"

echo "Dumping XML for $VM_NAME..."
sudo virsh dumpxml $VM_NAME > $XML_PATH

python3 - << 'PYEOF'
xml_path = "/tmp/performance-vm.xml"
with open(xml_path, "r") as f:
    content = f.read()

import re

# Print any kernel/initrd/bootloader blocks found before removal
print("--- Found old boot references ---")
print(re.findall(r'<kernel>.*?</kernel>', content, flags=re.DOTALL))
print(re.findall(r'<initrd>.*?</initrd>', content, flags=re.DOTALL))
print(re.findall(r'<bootloader>.*?</bootloader>', content, flags=re.DOTALL))

# Completely remove kernel, initrd, bootloader tags
content = re.sub(r'\s*<kernel>.*?</kernel>', '', content, flags=re.DOTALL)
content = re.sub(r'\s*<initrd>.*?</initrd>', '', content, flags=re.DOTALL)
content = re.sub(r'\s*<bootloader>.*?</bootloader>', '', content, flags=re.DOTALL)

# Ensure os type loader/kernel attributes are cleaned up if present inside <os>
content = re.sub(r'kernel=\'[^\']+\'', '', content)
content = re.sub(r'initrd=\'[^\']+\'', '', content)
content = re.sub(r'loader=\'[^\']+\'', '', content)

with open(xml_path, "w") as f:
    f.write(content)

print("--- Cleaned XML successfully ---")
PYEOF

echo "Redefining domain..."
sudo virsh define $XML_PATH
rm -f $XML_PATH

echo "Attempting to start $VM_NAME..."
sudo virsh start $VM_NAME
sudo virsh list --all
