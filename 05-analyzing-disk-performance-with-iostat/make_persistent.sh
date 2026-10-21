#!/bin/bash
# Make I/O Scheduler Changes Persistent

UDEV_RULE_FILE="/etc/udev/rules.d/60-io-schedulers.rules"
echo "Creating persistent I/O scheduler configuration..."

cat > "$UDEV_RULE_FILE" << 'UDEV_EOF'
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="kyber"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
UDEV_EOF

udevadm control --reload-rules
udevadm trigger
echo "Persistent udev rules created and reloaded successfully."
