#!/bin/bash
# I/O Scheduler Optimization Script

echo "I/O Scheduler Optimization Tool"
echo "==============================="

detect_storage_type() {
    local device=$1
    if [ -f "/sys/block/$device/queue/rotational" ]; then
        if [ "$(cat /sys/block/$device/queue/rotational)" = "0" ]; then
            echo "SSD"
        else
            echo "HDD"
        fi
    else
        echo "UNKNOWN"
    fi
}

recommend_scheduler() {
    local device=$1
    local storage_type=$(detect_storage_type $device)
    case $storage_type in
        "SSD") echo "kyber" ;;
        "HDD") echo "mq-deadline" ;;
        *) echo "mq-deadline" ;;
    esac
}

apply_optimization() {
    local device=$1
    local scheduler=$2
    echo "Applying optimization to $device with scheduler $scheduler..."
    echo $scheduler > /sys/block/$device/queue/scheduler
}

for device_path in /sys/block/*; do
    device=$(basename $device_path)
    if [[ $device =~ ^(loop|ram|dm-) ]]; then continue; fi
    storage_type=$(detect_storage_type $device)
    recommended=$(recommend_scheduler $device)
    
    echo "Device: $device | Type: $storage_type | Recommended: $recommended"
    apply_optimization $device $recommended
done

echo "Optimization completed!"
./check_schedulers.sh
