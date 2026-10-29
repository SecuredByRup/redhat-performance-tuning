#!/bin/bash

VM_NAME="performance-vm"
XML_PATH="/tmp/${VM_NAME}.xml"

echo "Dumping XML for $VM_NAME..."
sudo virsh dumpxml $VM_NAME > $XML_PATH

python3 - << 'PYEOF'
import re

xml_path = "/tmp/performance-vm.xml"
with open(xml_path, "r") as f:
    content = f.read()

# Remove obsolete kernel, initrd, or cmdline tags left over from initial installation
content = re.sub(r'\s*<kernel>.*?</kernel>', '', content, flags=re.DOTALL)
content = re.sub(r'\s*<initrd>.*?</initrd>', '', content, flags=re.DOTALL)
content = re.sub(r'\s*<cmdline>.*?</cmdline>', '', content, flags=re.DOTALL)

# Ensure os type has a proper hard disk boot order if missing
if "<boot dev='hd'/>" not in content:
    content = content.replace("<os>", "<os>\n    <boot dev='hd'/>")

with open(xml_path, "w") as f:
    f.write(content)

print("Cleaned up installer boot entries from XML.")
PYEOF

echo "Redefining domain..."
sudo virsh define $XML_PATH
rm -f $XML_PATH

echo "Starting $VM_NAME..."
sudo virsh start $VM_NAME

# Check status
sudo virsh list --all
