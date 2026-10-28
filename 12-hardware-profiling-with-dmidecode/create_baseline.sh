#!/bin/bash

BASELINE_DIR="hardware_baseline_$(date +%Y%m%d)"
mkdir -p "$BASELINE_DIR"

echo "Creating hardware performance baseline in: $BASELINE_DIR"

echo "$(date): Creating hardware baseline for $(hostname)" > "$BASELINE_DIR/baseline_info.txt"
sudo dmidecode --type 4 > "$BASELINE_DIR/cpu_baseline.txt"
sudo dmidecode --type 16,17 > "$BASELINE_DIR/memory_baseline.txt"
sudo dmidecode --type 0,1,2,3 > "$BASELINE_DIR/system_baseline.txt"

cat > "$BASELINE_DIR/compare_baseline.sh" << 'COMPARE_EOF'
#!/bin/bash

echo "=== Hardware Configuration Comparison ==="
echo "Baseline created: $(cat baseline_info.txt)"
echo "Current date: $(date)"
echo

echo "--- CPU Comparison ---"
BASELINE_CPU=$(grep "Version" cpu_baseline.txt | head -1 | cut -d: -f2 | xargs)
CURRENT_CPU=$(sudo dmidecode --type 4 | grep "Version" | head -1 | cut -d: -f2 | xargs)

if [ "$BASELINE_CPU" = "$CURRENT_CPU" ]; then
    echo "✅ CPU unchanged: $CURRENT_CPU"
else
    echo "⚠️  CPU changed!"
    echo "   Baseline: $BASELINE_CPU"
    echo "   Current:  $CURRENT_CPU"
fi

echo "--- Memory Comparison ---"
BASELINE_MEMORY=$(grep "Size:" memory_baseline.txt | grep -v "No Module Installed" | \
                  awk '{sum += $2} END {print sum}')
CURRENT_MEMORY=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
                 awk '{sum += $2} END {print sum}')

if [ "$BASELINE_MEMORY" = "$CURRENT_MEMORY" ]; then
    echo "✅ Memory unchanged: $CURRENT_MEMORY MB"
else
    echo "⚠️  Memory changed!"
    echo "   Baseline: $BASELINE_MEMORY MB"
    echo "   Current:  $CURRENT_MEMORY MB"
fi
COMPARE_EOF

chmod +x "$BASELINE_DIR/compare_baseline.sh"
echo "Baseline created successfully!"
ls -la "$BASELINE_DIR"
