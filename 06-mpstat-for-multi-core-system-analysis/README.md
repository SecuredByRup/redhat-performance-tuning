# Lab 6: Using mpstat for Multi-Core System Analysis

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-Enterprise%20Linux-CC0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS Stream](https://img.shields.io/badge/CentOS-Stream-26252D?style=for-the-badge&logo=centos&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Server-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## Overview
This repository contains hands-on lab exercises, automation scripts, and performance tracking utilities for **Lab 6: Using mpstat for Multi-Core System Analysis** under the Red Hat performance tuning curriculum. The primary focus is on examining multi-core CPU architectures, capturing granular per-core utilization metrics using `mpstat`, generating synthetic CPU stress workloads, identifying resource bottlenecks, and optimizing process distribution via CPU affinity and load balancing techniques.

---

## Directory Structure
```text
06-using-mpstat-for-multi-core-system-analysis/
├── baseline_cpu.sh
├── cpu_analysis.sh
├── detect_bottlenecks.sh
├── cpu_affinity_test.sh
├── optimize_processes.sh
├── cpu_dashboard.sh
├── historical_analysis.sh
├── generate_report.sh
├── setup_monitoring.sh
└── screenshots/
    ├── mpstat-realtime-monitoring.png
    └── cpu-bottleneck-analysis.png
```

---

## Technical Summary & Hands-On Tasks

### Task 1: Environment Preparation & Tool Provisioning
* **Architecture Inspection (`lscpu`, `nproc`)**: Verified system logical processors (4 vCPUs), socket topology, thread count, and cache structures.
* **Package Installation (`sysstat`)**: Installed the `sysstat` performance toolkit to gain access to `mpstat` and `sar` binaries.
* **Data Collection Services**: Enabled and activated the `sysstat` systemd service for persistent background metrics aggregation.

### Task 2: Basic `mpstat` Telemetry & Baseline Automation
* **Command Line Syntax (`mpstat -P ALL`)**: Analyzed key metrics including user execution (`%usr`), kernel system time (`%sys`), I/O wait latency (`%iowait`), and hardware/software interrupt handling (`%irq`, `%soft`).
* **Automated Baseline Capture (`baseline_cpu.sh`)**: Created an automated script capturing initial 10-second rolling averages, architecture parameters, system load averages, and top CPU process consumers.

### Task 3: Advanced Load Distribution & Bottleneck Identification
* **Stress Workload Simulation (`stress`)**: Simulated single-threaded, multi-core, and I/O-heavy pressure conditions using synthetic load generation tools.
* **Granular Core Analysis (`cpu_analysis.sh`)**: Tracked utilization shifts under varying stress profiles and logged peak metrics.
* **Automated Threshold Detection (`detect_bottlenecks.sh`)**: Implemented `awk`-based scripts to evaluate per-core load imbalances, flagging high-load (>80%), low-activity (<10%), and I/O wait (>20%) scenarios.

### Task 4: Resource Optimization & Interactive Monitoring
* **CPU Affinity Enforcement (`cpu_affinity_test.sh`, `taskset`)**: Pinned resource-intensive tasks to specific logical cores to isolate compute tasks and measure per-core performance response.
* **Process Distribution Tuning (`optimize_processes.sh`)**: Demonstrated performance impacts of unbalanced process stacking versus balanced multi-core load dispersion.
* **Interactive Dashboard (`cpu_dashboard.sh`)**: Built a terminal-based real-time telemetry console rendering system overviews, per-core metrics, and top process activity.

### Task 5: Reporting & Automated Daemon Setup
* **Historical Data Parsing (`historical_analysis.sh`)**: Extracted and summarized metrics recorded by System Activity Reporter (`sar`).
* **Report Generation (`generate_report.sh`)**: Programmatically output formatted performance reports summarizing hardware specs, current utilization, and load test outcomes.
* **Continuous Monitoring Daemon (`setup_monitoring.sh`)**: Configured background logging scripts and directory structures to support long-term continuous system monitoring.

---

## Verification & Demonstrations

### 1. Real-Time `mpstat` Core Analysis
Captured execution of `mpstat -P ALL 2 5` displaying live utilization across all 4 logical CPUs, showing baseline idle percentages around ~97-98%:

![mpstat Real-Time Monitoring](screenshots/mpstat-realtime-monitoring.png)

### 2. Automated Bottleneck Detection Execution
Ran the custom `detect_bottlenecks.sh` script to parse recorded metric logs (`cpu_stats.log`), calculating per-core user and system totals across CPU 0 through CPU 3:

![CPU Bottleneck Analysis](screenshots/cpu-bottleneck-analysis.png)

---

## Conclusion
Through this lab, key multi-core performance analysis methodologies were applied using `mpstat` and supporting Linux utilities. By evaluating individual core workloads, identifying CPU bottlenecks, and testing core affinity using `taskset`, system administrators can effectively troubleshoot compute bottlenecks, prevent resource starvation, and optimize workload distribution across multi-processor environments.