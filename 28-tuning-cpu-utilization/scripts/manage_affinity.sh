#!/bin/bash
show_topology() {
    echo "=== CPU Topology ==="
    lscpu | grep -E "(CPU\(s\)|Thread|Core|Socket)"
    echo ""
}
show_topology
