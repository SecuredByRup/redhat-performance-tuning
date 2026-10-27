#!/bin/bash

echo "=== Swappiness Comparison Summary ==="
echo "Generated: $(date)"
echo ""

for file in swappiness_*.log; do
    if [ -f "$file" ]; then
        swappiness_val=$(echo $file | grep -o '[0-9]\+')
        echo "Swappiness $swappiness_val:"
        echo "  Swap in/out activity:"
        grep -E "(si|so)" $file | tail -5 | awk '{print "    si: " $7 ", so: " $8}'
        echo ""
    fi
done
