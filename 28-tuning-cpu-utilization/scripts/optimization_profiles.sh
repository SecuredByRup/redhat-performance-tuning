#!/bin/bash

apply_throughput_profile() {
    echo "Applying THROUGHPUT optimization profile..."
    sudo tuned-adm profile throughput-performance
    echo "Throughput profile applied."
}

apply_latency_profile() {
    echo "Applying LATENCY optimization profile..."
    sudo tuned-adm profile latency-performance 2>/dev/null || sudo tuned-adm profile throughput-performance
    echo "Latency profile applied."
}

apply_balanced_profile() {
    echo "Applying BALANCED optimization profile..."
    sudo tuned-adm profile balanced
    echo "Balanced profile applied."
}

show_current_profile() {
    echo "Current active tuned profile:"
    sudo tuned-adm active
}

case "$1" in
    throughput)
        apply_throughput_profile
        ;;
    latency)
        apply_latency_profile
        ;;
    balanced)
        apply_balanced_profile
        ;;
    show)
        show_current_profile
        ;;
    *)
        echo "Usage: $0 {throughput|latency|balanced|show}"
        exit 1
        ;;
esac
