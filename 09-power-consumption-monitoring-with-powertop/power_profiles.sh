#!/bin/bash

PROFILE_DIR="/etc/power-profiles"
sudo mkdir -p "$PROFILE_DIR"

# Performance Profile
sudo tee "$PROFILE_DIR/performance.conf" << 'PERF_EOF'
CPU_GOVERNOR=performance
CPU_MAX_FREQ=100
LAPTOP_MODE=0
USB_AUTOSUSPEND=0
WIFI_POWER_SAVE=off
PERF_EOF

# Balanced Profile
sudo tee "$PROFILE_DIR/balanced.conf" << 'BAL_EOF'
CPU_GOVERNOR=ondemand
CPU_MAX_FREQ=80
LAPTOP_MODE=1
USB_AUTOSUSPEND=1
WIFI_POWER_SAVE=on
BAL_EOF

# Power Save Profile
sudo tee "$PROFILE_DIR/powersave.conf" << 'SAVE_EOF'
CPU_GOVERNOR=powersave
CPU_MAX_FREQ=50
LAPTOP_MODE=5
USB_AUTOSUSPEND=1
WIFI_POWER_SAVE=on
SAVE_EOF

switch_profile() {
    local profile="$1"
    local config_file="$PROFILE_DIR/${profile}.conf"
    
    if [ ! -f "$config_file" ]; then
        echo "Profile $profile not found!"
        return 1
    fi
    
    echo "Switching to $profile profile..."
    source "$config_file"
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$CPU_GOVERNOR" | sudo tee "$cpu" >/dev/null 2>&1
    done
    
    if [ -f /sys/devices/system/cpu/intel_pstate/max_perf_pct ]; then
        echo "$CPU_MAX_FREQ" | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null
    fi
    
    echo "$LAPTOP_MODE" | sudo tee /proc/sys/vm/laptop_mode >/dev/null
    echo "Profile $profile applied successfully!"
}

case "$1" in
    performance|balanced|powersave)
        switch_profile "$1"
        ;;
    list)
        ls "$PROFILE_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//'
        ;;
    *)
        echo "Usage: $0 {performance|balanced|powersave|list}"
        ;;
esac
