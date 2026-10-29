#!/bin/bash

VM_NAME="performance-vm"
XML_PATH="/tmp/${VM_NAME}.xml"

# Force stop the VM if it's running/stuck
sudo virsh destroy $VM_NAME 2>/dev/null || true

echo "Dumping XML for $VM_NAME..."
sudo virsh dumpxml $VM_NAME > $XML_PATH

python3 - << 'PYEOF'
xml_path = "/tmp/performance-vm.xml"
with open(xml_path, "r") as f:
    content = f.read()

balloon_block = """  <memballoon model='virtio'>
    <stats period='10'/>
  </memballoon>"""

# Check if memballoon already exists, if not insert it before </devices>
if "<memballoon" not in content:
    content = content.replace("</devices>", balloon_block + "\n  </devices>")
else:
    import re
    content = re.sub(r'<memballoon.*?</memballoon>', balloon_block, content, flags=re.DOTALL)

with open(xml_path, "w") as f:
    f.write(content)

print("Memballoon block successfully injected into XML.")
PYEOF

echo "Defining updated domain..."
sudo virsh define $XML_PATH
rm -f $XML_PATH

echo "Starting $VM_NAME..."
sudo virsh start $VM_NAME
echo "Memory ballooning configuration applied and VM started!"
