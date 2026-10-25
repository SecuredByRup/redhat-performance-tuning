#!/bin/bash

echo "=========================================="
echo "  COMPREHENSIVE HARDWARE PERFORMANCE ANALYSIS"
echo "=========================================="
echo "Generated on: $(date)"
echo "System: $(hostname)"
echo "=========================================="

print_section() {
    echo -e "\n" 
    echo "===========================================" 
    echo "  $1"
    echo "==========================================="
}

# CPU Performance Analysis
print_section "CPU PERFORMANCE ANALYSIS"

CPU_MODEL=$(sudo dmidecode --type 4 | grep "Version" | head -1 | cut -d: -f2 | xargs)
CPU_CORES=$(sudo dmidecode --type 4 | grep "Core Count" | head -1 | awk '{print $3}')
CPU_THREADS=$(sudo dmidecode --type 4 | grep "Thread Count" | head -1 | awk '{print $3}')
CPU_CURRENT_SPEED=$(sudo dmidecode --type 4 | grep "Current Speed" | head -1 | awk '{print $3}')
CPU_MAX_SPEED=$(sudo dmidecode --type 4 | grep "Max Speed" | head -1 | awk '{print $3}')

echo "CPU Model: $CPU_MODEL"
echo "Cores: $CPU_CORES | Threads: $CPU_THREADS"
echo "Current Speed: $CPU_CURRENT_SPEED MHz | Max Speed: $CPU_MAX_SPEED MHz"

# Memory Performance Analysis
print_section "MEMORY PERFORMANCE ANALYSIS"

TOTAL_MEMORY_MB=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
                  awk '{sum += $2} END {print sum}')
TOTAL_MEMORY_GB=$((TOTAL_MEMORY_MB / 1024))
MEMORY_MODULES=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | wc -l)
MEMORY_SPEED=$(sudo dmidecode --type 17 | grep "Speed:" | grep -v "Unknown" | head -1 | awk '{print $2}')

echo "Total Memory: ${TOTAL_MEMORY_GB} GB (${TOTAL_MEMORY_MB} MB)"
echo "Memory Modules: $MEMORY_MODULES"
echo "Memory Speed: $MEMORY_SPEED MHz"

# System Configuration Analysis
print_section "SYSTEM CONFIGURATION ANALYSIS"

BIOS_DATE=$(sudo dmidecode --type 0 | grep "Release Date" | awk '{print $3}')
BIOS_VERSION=$(sudo dmidecode --type 0 | grep "Version" | cut -d: -f2 | xargs)

echo "BIOS Version: $BIOS_VERSION"
echo "BIOS Date: $BIOS_DATE"

print_section "ANALYSIS COMPLETE"
