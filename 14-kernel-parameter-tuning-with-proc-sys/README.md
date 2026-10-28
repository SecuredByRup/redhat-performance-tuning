# Lab 14: Kernel Parameter Tuning with `/proc/sys`

<p align="center">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat" />
  <img src="https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash" />
</p>

---

## Executive Summary

This lab demonstrates practical system performance optimization on Linux systems using virtual filesystem runtime interfaces (`/proc/sys`) and the `sysctl` management utility. It covers baseline inspection, live kernel parameter tuning across memory management (`vm`), TCP networking (`net`), and file handles (`fs`), followed by I/O benchmark evaluation and long-term configuration persistence.

---

## Objectives

1. **Explore & Inspect Kernel Parameters:** Understand `/proc/sys` structure and extract runtime values using direct file inspection and `sysctl`.
2. **Dynamic Kernel Tuning:** Modify live kernel behavior for memory (`vm.swappiness`, `vm.dirty_ratio`), network buffers (`net.ipv4.tcp_rmem`, `net.ipv4.tcp_wmem`), and file resource limits (`fs.file-max`).
3. **Performance Benchmarking:** Analyze system performance and I/O rates using custom scripts and system utilities (`dd`, `sync`).
4. **Configuration Persistence:** Persist optimized runtime configurations via drop-in configuration files under `/etc/sysctl.d/` and validate settings.

---

## Repository Structure

```text
14-kernel-parameter-tuning-with-proc-sys/
├── baseline_check.sh
├── io_test.sh
├── memory_test.sh
├── monitor_performance.sh
├── validate_tuning.sh
├── README.md
└── screenshots/
    ├── lab14_baseline_and_io_test.png
    └── lab14_persistence_and_validation.png
```

---

## Step-by-Step Implementation

### Task 1: Baseline Parameter Inspection

A baseline check script (`baseline_check.sh`) was executed to inspect the initial system state across memory management, TCP buffers, and file handle settings.

```bash
./baseline_check.sh
```

**Key Parameters Evaluated:**
* `vm.swappiness`: Controls kernel aggressiveness regarding swapping out anonymous memory pages.
* `vm.dirty_ratio` & `vm.dirty_background_ratio`: Defines system memory percentages triggering asynchronous and synchronous dirty page disk flushes.
* `net.ipv4.tcp_rmem` & `net.ipv4.tcp_wmem`: Defines min, default, and max TCP buffer allocation sizes in bytes.
* `fs.file-max`: Sets system-wide ceiling for file handles allocated by the kernel.

---

### Task 2: Live Runtime Parameter Tuning

Dynamic modifications were applied directly using `sysctl` commands to adjust memory management, write-back ratios, and TCP window buffers for high-throughput environments:

```bash
# Adjust memory swappiness & cache pressure
sudo sysctl vm.swappiness=10
sudo sysctl vm.dirty_ratio=15
sudo sysctl vm.dirty_background_ratio=5
sudo sysctl vm.vfs_cache_pressure=50

# Tune TCP network buffer allocations
sudo sysctl net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl net.ipv4.tcp_wmem="4096 65536 16777216"
sudo sysctl net.core.rmem_max=16777216
sudo sysctl net.core.wmem_max=16777216

# Increase file descriptor capacity
sudo sysctl fs.file-max=1048576
```

---

### Task 3: Performance Testing & Verification

An automated I/O benchmark script (`io_test.sh`) was run to measure sequential write performance, read performance post-cache dropping (`drop_caches`), and random block I/O throughput.

![Baseline Check and I/O Performance Benchmark](screenshots/lab14_baseline_and_io_test.png)

---

### Task 4: Persistence and Automated Validation

To ensure configuration settings persist across system reboots, rules were saved to a drop-in configuration file in `/etc/sysctl.d/99-performance-tuning.conf` and reloaded into the running kernel using `sysctl -p`.

```bash
sudo tee /etc/sysctl.d/99-performance-tuning.conf << 'EOF'
# Memory management
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# Network tuning
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

# File system tuning
fs.file-max = 1048576
EOF

# Load settings from file
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

An automated validation script (`validate_tuning.sh`) was run to verify parameter consistency between active kernel memory and persistent configuration files.

![Sysctl Persistence and Parameter Validation](screenshots/lab14_persistence_and_validation.png)

---

## Conclusion

Through this lab, dynamic kernel parameter tuning was successfully implemented and verified using `/proc/sys` interfaces and `sysctl`. Custom parameters optimized system memory swapping behavior, optimized TCP socket buffers for higher network capacity, and expanded system file handle ceilings. Applying settings through `/etc/sysctl.d/` guaranteed system configuration persistence, establishing a robust foundation for enterprise Red Hat performance optimization.