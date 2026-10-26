#!/bin/bash

show_top() {
    echo "=== TOP RESOURCE CONSUMERS ==="
    echo "Top 10 CPU consumers:"
    ps aux --sort=-%cpu | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%-8s %6s %5.1f%% %5.1f%% %s\n", $1, $2, $3, $4, $11}'
    echo
    echo "Top 10 Memory consumers:"
    ps aux --sort=-%mem | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%-8s %6s %5.1f%% %5.1f%% %s\n", $1, $2, $3, $4, $11}'
}

search_processes() {
    local term=$1
    echo "=== PROCESSES MATCHING: $term ==="
    ps aux | grep -i "$term" | grep -v grep
}

generate_report() {
    local report_file="process_report_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "=== SYSTEM PROCESS ANALYSIS REPORT ==="
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime)"
        echo
        show_top
    } > "$report_file"
    echo "Report saved to: $report_file"
}

case "$1" in
    -t|--top) show_top ;;
    -s|--search) search_processes "$2" ;;
    -r|--report) generate_report ;;
    *) echo "Usage: $0 {--top|--search <term>|--report}" ;;
esac
