# Lab 11: Profiling System Hardware with `dmesg`

<p align="center">
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat Enterprise Linux" />
  <img src="https://img.shields.io/badge/Linux_Kernel-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux Kernel" />
  <img src="https://img.shields.io/badge/Bash_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash Scripting" />
  <img src="https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS Cloud" />
</p>

---

## Executive Summary

Hardware profiling and early-stage system diagnostics are critical responsibilities for Red Hat Enterprise Linux (RHEL) administrators and performance engineers. The kernel ring buffer contains a real-time, low-level stream of events generated during initial boot and ongoing hardware operations. 

This lab explores system hardware profiling techniques utilizing the kernel ring buffer management utility **`dmesg`**. Across eight hands-on tasks, custom Shell and Bash scripts were developed to inspect CPU topologies, memory maps (E820), storage device controllers (NVMe/SATA), virtualized network adapters, real-time error streams, and overall hardware health.

---

## Environment & Prerequisites

* **Operating System**: Red Hat Enterprise Linux 9 / RHEL-compatible distribution (CentOS Stream)
* **Kernel Version**: `5.14.0-654.el9.x86_64`
* **Target Architecture**: `x86_64` (AWS Cloud Instance)
* **Repository Context**: `SecuredByRup/redhat-performance-tuning`
* **Lab Directory**: `11-profiling-sysng-system-hardware-with-dmesg`

---

## Task Breakdown & Technical Implementation

### Task 1: Understanding `dmesg` & Kernel Ring Buffer

The kernel ring buffer (`/dev/kmsg`) stores low-level messages emitted by the Linux kernel. The `dmesg` utility allows users to examine, filter, and control this buffer.

#### Key Commands Executed:
```bash
# Print kernel ring buffer with human-readable boot-relative timestamps
dmesg -T

# Display kernel facility and priority log levels in human-readable notation
dmesg -x

# Filter kernel log levels specifically for errors and warnings
dmesg -l err,warn
```

![dmesg Boot Timestamps & CPU Analysis](dmesg-boot-timestamps-and-cpu-analysis.png)
*Figure 1: Executing `dmesg -T | head -15` showing boot image configuration, BIOS-provided E820 RAM maps, and CPU topology parsing.*

---

### Task 2: Analyzing Hardware Detection Messages

Automated diagnostic scripts were built to isolate subsystem detection logs for CPU, memory, and storage controllers.

#### CPU Topology Analysis (`cpu_analysis.sh`):
```bash
#!/bin/bash
echo "=== CPU Hardware Detection Analysis ==="
echo "1. CPU Detection Messages:"
dmesg | grep -i "cpu" | head -10
echo "2. CPU Features:"
dmesg | grep -i "cpu.*feature" | head -5
echo "3. CPU Frequency Information:"
dmesg | grep -i "cpufreq\|scaling" | head -5
echo "4. CPU Cache Information:"
dmesg | grep -i "cache" | head -5
EOF
```

#### Memory Detection Analysis (`memory_analysis.sh`):
```bash
#!/bin/bash
echo "=== Memory Hardware Detection Analysis ==="
echo "1. Memory Detection:"
dmesg | grep -i "memory" | grep -v "reserve" | head -10
echo "2. Memory Mapping (E820):"
dmesg | grep -i "e820" | head -5
echo "3. Available Memory:"
dmesg | grep -i "available.*memory\|usable.*memory"
EOF
```

![Memory Detection & E820 Mapping](memory-detection-and-e820-mapping.png)
*Figure 2: Execution of `./memory_analysis.sh` revealing ACPI table memory reservations and BIOS-e820 physical RAM layout map.*

---

### Task 3: Storage & Network Diagnostics

Storage and filesystem lifecycle events (XFS/EXT4/FAT) were audited alongside storage controller queues.

#### Storage Diagnostics Script (`diagnose_storage.sh`):
```bash
#!/bin/bash
echo "=== Storage Diagnostics ==="
echo "1. Checking for I/O errors:"
dmesg | grep -i "i/o error\|input/output error"

echo "2. Checking for SMART errors:"
dmesg | grep -i "smart\|dma"

echo "3. Checking for filesystem errors:"
dmesg | grep -i "filesystem error\|ext4-fs error\|xfs_error"

echo "4. Recent storage-related messages:"
dmesg | grep -E "nvme|sd[a-z]|xfs|ext4|fat" | tail -10
```

![Storage Diagnostics & NVMe Detection](storage-diagnostics-and-nvme-detection.png)
*Figure 3: Storage analysis output confirming NVMe controllers (`nvme0n1`, `nvme1`), XFS recovery sequence, and EXT4 partition mount statuses.*

---

### Task 4 & Task 5: Advanced Filtering & Automated Hardware Health Check

To transition from manual inspection to automated monitoring, a comprehensive health check script was deployed (`hardware_health_check.sh`). The script parses critical health indicators: thermal governors, hardware timeouts, I/O failures, and deprecated drivers.

#### Health Check Script Execution:
```bash
./hardware_health_check.sh
```

![Hardware Health Check Report](hardware-health-check-report.png)
*Figure 4: Automated health check output showing clean thermal statuses, system stability stats, and deprecation notices for enterprise storage drivers.*

---

### Task 6 & Task 7: Boot Performance & Real-Time Monitoring

Boot delays and device probe latency were analyzed via timeline correlation.

#### Real-Time Kernel Monitor (`realtime_monitor.sh`):
```bash
#!/bin/bash
echo "Starting real-time kernel message monitoring..."
dmesg -w | while read line; do
    if echo "$line" | grep -qi "error\|fail\|warn\|timeout\|hardware\|thermal\|i/o"; then
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] ALERT: $line"
    fi
done
```

---

### Task 8: Comprehensive Hardware Profiling Report

A consolidated reporting tool (`hardware_profile.sh`) was implemented to compile complete system hardware audits into timestamped text artifacts.

```bash
./hardware_profile.sh
```

![Comprehensive Hardware Profile Summary](comprehensive-hardware-profile-summary.png)
*Figure 5: Output generated by `hardware_profile.sh` summarizing system health counts, PCI devices, USB bus detection, and graphics framebuffers.*

---

## Key Hardware Findings

1. **System Topology**:
   * **Virtualization**: AWS EC2 Cloud Hypervisor (KVM/Xen backing).
   * **CPU Architecture**: Single socket, multi-thread virtual CPU configuration with active NX protection and APIC static calls.
2. **Memory Map (E820)**:
   * System memory correctly partitioned into `usable`, `reserved`, `ACPI data`, and `ACPI NVS` pools across low and high memory boundaries.
3. **Storage Controller & Filesystems**:
   * Dual NVMe virtual drives identified (`nvme0`, `nvme1`).
   * Primary root formatted as **XFS** (`nvme0n1p4`), successfully performing log recovery during initialization.
   * Auxiliary drives formatted as **EXT4** (`nvme0n1p3`) and **FAT** (`nvme0n1p2`).
4. **Network Stack**:
   * High-speed Elastic Network Adapter (`ena`) loaded, automatically renamed from `eth0` to `ens5` following Predictable Network Interface Naming conventions.

---

## Verification & Key Learnings

Through this lab, the following core RHEL performance tuning competencies were established:

* **Ring Buffer Mastery**: Understanding how kernel buffer wrap-around functions and how to persist critical kernel logs via `journalctl -k`.
* **Precision Filtering**: Leveraging `dmesg` log levels (`err`, `warn`, `info`, `crit`) and facilities (`kern`, `daemon`, `boot`) for rapid troubleshooting.
* **Automated Parsing**: Scripting custom Bash diagnostics to convert raw hardware probe outputs into actionable enterprise health reports.

---

## Conclusion

Kernel-level profiling via `dmesg` provides indispensable visibility into bare-metal and virtualized enterprise hardware platforms. By mastering buffer navigation, regex filtering, and automated diagnostic scripting, system administrators can quickly diagnose hardware faults, optimize device initialization during boot, and maintain continuous infrastructure reliability in RHEL environments.
