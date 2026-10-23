#!/bin/bash
show_help() {
    echo "Priority Manager Script"
    echo "Usage: $0 [option] [pid] [nice_value]"
    echo "Options: list, renice, monitor"
}

list_priorities() {
    echo "Current Process Priorities:"
    ps -eo pid,ppid,ni,comm --sort=-ni | head -20
}

renice_process() {
    local pid=$1
    local nice_value=$2
    if [ -z "$pid" ] || [ -z "$nice_value" ]; then
        echo "Error: PID and nice value required"
        return 1
    fi
    if [ "$nice_value" -lt 0 ]; then
        sudo renice "$nice_value" "$pid"
    else
        renice "$nice_value" "$pid"
    fi
}

monitor_priorities() {
    echo "Monitoring process priorities (Press Ctrl+C to stop)..."
    while true; do
        clear
        echo "Process Priority Monitor - $(date)"
        echo "=================================="
        ps -eo pid,ppid,ni,%cpu,%mem,comm --sort=-%cpu | head -15
        sleep 2
    done
}

case $1 in
    list) list_priorities ;;
    renice) renice_process $2 $3 ;;
    monitor) monitor_priorities ;;
    *) show_help ;;
esac
