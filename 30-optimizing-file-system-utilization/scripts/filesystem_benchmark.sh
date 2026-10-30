#!/bin/bash
# ==============================================================================
# File System Performance Benchmark Script
# ==============================================================================

TARGETS=("/mnt/optimized-fs" "/mnt/ext4-tuned" "/mnt/xfs-tuned" "/mnt/btrfs-tuned")

for dir in "${TARGETS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Skipping $dir (mount point not found)"
        continue
    fi

    echo "=================================================="
    echo "Benchmarking File System: $dir"
    echo "=================================================="
    cd "$dir" || continue

    # Clean up any leftover test artifacts
    rm -f test_large.dat small_*.txt

    # Test 1: Sequential Write Performance (500MB file with sync)
    echo "--- 1. Large File Write (500MB) ---"
    time dd if=/dev/zero of=test_large.dat bs=1M count=500 conv=fdatasync 2>&1

    # Test 2: Sequential Read Performance (500MB file)
    echo "--- 2. Large File Read (500MB) ---"
    time dd if=test_large.dat of=/dev/null bs=1M 2>&1

    # Test 3: Metadata & Small File Creation (1,000 files)
    echo "--- 3. Small File Creation (1,000 files) ---"
    time bash -c 'for i in {1..1000}; do echo "Benchmark data $i" > small_$i.txt; done'

    # Test 4: Small File Deletion Performance
    echo "--- 4. Small File Deletion (1,000 files) ---"
    time rm -f small_*.txt

    # Clean up remaining large test file
    rm -f test_large.dat
    echo ""
done

echo "=== All File System Benchmarks Completed Successfully ==="
