#!/bin/bash
# Check I/O Schedulers for All Block Devices

echo "Current I/O Schedulers:"
echo "======================"

for device in /sys/block/*/queue/scheduler; do
    device_name=$(echo $device | cut -d'/' -f4)
    # Skip loop, ram, and device-mapper virtual devices
    if [[ ! $device_name =~ ^(loop|ram|dm-) ]]; then
        echo -n "$device_name: "
        if [ -f "$device" ]; then
            cat "$device"
        else
            echo "N/A"
        fi
    fi
done

echo ""
echo "Available schedulers are shown in brackets []"
echo "Current scheduler is shown in square brackets [current]"
