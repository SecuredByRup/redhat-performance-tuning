#!/bin/bash
LOG_FILE="/var/log/auto-power-mgmt.log"

log_message() {
    echo "$(date): $1" | sudo tee -a "$LOG_FILE"
}

get_battery_level() {
    if [ -f /sys/class/power_supply/BAT0/capacity ]; then
        cat /sys/class/power_supply/BAT0/capacity
    else
        echo "100"
    fi
}

get_power_status() {
    if [ -f /sys/class/power_supply/ADP1/online ]; then
        cat /sys/class/power_supply/ADP1/online
    elif [ -f /sys/class/power_supply/AC/online ]; then
        cat /sys/class/power_supply/AC/online
    else
        echo "1"
    fi
}

while true; do
    battery_level=$(get_battery_level)
    on_ac=$(get_power_status)
    
    if [ "$on_ac" = "1" ]; then
        log_message "On AC power - applying performance profile"
        /usr/local/bin/power_profiles.sh performance
    elif [ "$battery_level" -gt 50 ]; then
        log_message "Battery level $battery_level% - applying balanced profile"
        /usr/local/bin/power_profiles.sh balanced
    else
        log_message "Battery level $battery_level% - applying powersave profile"
        /usr/local/bin/power_profiles.sh powersave
    fi
    
    sleep 60
done
