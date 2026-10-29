# Lab 20: Comprehensive Performance Tuning Review (Capstone)

<p align="center">
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat Enterprise Linux" />
  <img src="https://img.shields.io/badge/Linux_Kernel-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux Kernel" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash Scripting" />
  <img src="https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS EC2" />
</p>

## Executive Summary
This capstone project synthesizes enterprise-level Linux performance analysis, baseline telemetry, system tuning, and automated verification into a single unified framework. Executed on a cloud-hosted Enterprise Linux instance (AMD EPYC 7571, 4 vCPUs, 15GiB RAM, NVMe storage), this lab demonstrates full-stack performance tuning across CPU, memory subsystems, block I/O schedulers, and persistent kernel runtime parameters (`sysctl`).

---

## Architecture & Directory Structure
All telemetry, scripts, automated analyzers, and test results are modularized within the local laboratory environment:

```text
20-comprehensive-performance-tuning-review/
├── cpu-data/               # CPU telemetry logs (sar, top, perf stat)
├── memory-data/            # Memory usage & swap activity logs
├── disk-data/              # iostat and block device telemetry
├── network-data/           # Interface device statistics
├── reports/                # Automated analysis & final consolidated reports
├── test-results/           # Post-optimization workload metrics
├── screenshots/            # Visual validation artifacts
├── monitor-system.sh       # Baseline real-time monitoring collector
├── generate-load.sh        # Controlled multi-resource stress generator
├── analyze-cpu.sh          # Automated CPU telemetry evaluator
├── analyze-memory.sh       # Automated RAM/Swap analyzer
├── analyze-disk.sh         # Automated Filesystem & I/O wait inspector
├── optimize-cpu.sh         # Process priority & governor optimization
├── optimize-memory.sh      # Cache management & vm.swappiness persistent tuning
├── optimize-disk.sh        # Block I/O scheduler & temporary storage cleaner
├── optimize-system.sh      # Persistent kernel sysctl.d & limits.conf configuration
├── performance-test.sh     # Stress validation testing suite
├── generate-final-report.sh# Summary aggregator script
└── setup-monitoring.sh     # Automated cron monitoring installer
```

---

## Execution Workflow & Visual Evidence

### Task 1 & 2: Data Collection & System Analysis
Telemetry was collected across all subsystem domains. The automated script `analyze-cpu.sh` evaluated CPU hardware topology and baseline system load metrics.

![CPU Hardware and Baseline Telemetry](screenshots/01-cpu-hardware-analysis.png)
*Figure 1: Automated CPU Analysis output displaying system topology (AMD EPYC 7571, 4 vCPUs) and baseline load averages.*

---

### Task 3: Performance Optimization Implementation
Subsystem optimizations were applied targeting specific system metrics:
* **Memory Subsystem:** Set runtime memory swappiness (`vm.swappiness = 10`) to prioritize physical memory retentiveness over swap space usage.
* **Block Storage:** Detected active NVMe storage channels (`/sys/block/nvme0n1` and `nvme1n1`) and aligned I/O operations with modern low-latency block handlers (`none` / `mq-deadline`).
* **Kernel Runtime (`sysctl.d`):** Configured persistent socket buffer limits, dirty ratio writebacks (`dirty_ratio = 15`), and file descriptor resource limits (`limits.conf`).

![Process Telemetry and Memory Optimization](screenshots/02-process-telemetry-and-tunings.png)
*Figure 2: Evaluation of top consuming processes, system swappiness tuning, and NVMe block device queue scheduler discovery.*

---

### Task 4: Stress Validation, Final Reporting & Automated Monitoring
Post-optimization stress tests were conducted using multi-threaded resource generators (`stress-ng`, `iostat`, `sar`). The final report generator aggregated all system parameters and tuning validation logs.

![NVMe Schedulers and Final Performance Report](screenshots/03-nvme-scheduler-and-final-report.png)
*Figure 3: Verification of active NVMe block schedulers and execution of the final consolidated performance report.*

---

## Implemented Optimizations & Persistent Configuration

### 1. Persistent Kernel Parameters (`/etc/sysctl.d/99-performance-tuning.conf`)
```ini
# Network Socket Tuning
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Virtual Memory Tuning
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.swappiness = 10

# File System Allocation Limits
fs.file-max = 2097152
```

### 2. User & System Resource Limits (`/etc/security/limits.conf`)
```text
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
```

---

## Conclusion
This capstone review successfully established an end-to-end performance engineering lifecycle on Enterprise Linux. By combining historical data analysis (`sar`), process-level telemetry (`ps`, `perf`), target tuning (`sysctl`, `swappiness`, `I/O schedulers`), and automated cron-based daily status reporting, the environment was transformed into a stable, optimized, and continuously monitored platform.