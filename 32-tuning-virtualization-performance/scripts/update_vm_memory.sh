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

memory_backing_block = """  <memoryBacking>
    <hugepages/>
    <nosharepages/>
    <locked/>
  </memoryBacking>"""

numatune_block = """  <numatune>
    <memory mode='strict' nodeset='0'/>
  </numatune>"""

# Insert memoryBacking after currentMemory or memory tag if not present
if "<memoryBacking>" not in content:
    if "</currentMemory>" in content:
        content = content.replace("</currentMemory>", "</currentMemory>\n" + memory_backing_block)
    elif "</memory>" in content:
        content = content.replace("</memory>", "</memory>\n" + memory_backing_block)

# Insert numatune right after the opening <domain ...> tag if not present
if "<numatune>" not in content:
    content = re.sub(r'(<domain[^>]*>)', r'\1\n' + numatune_block, content, count=1)

with open(xml_path, "w") as f:
    f.write(content)

print("XML memory and NUMA blocks successfully injected.")
PYEOF

echo "Defining updated domain..."
sudo virsh define $XML_PATH
rm -f $XML_PATH
echo "Memory and NUMA configuration applied successfully for $VM_NAME!"
