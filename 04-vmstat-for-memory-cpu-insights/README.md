# Lab 4: Exploring vmstat for Memory and CPU Insights

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-Enterprise%20Linux-CC0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS Stream](https://img.shields.io/badge/CentOS-Stream-26252D?style=for-the-badge&logo=centos&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Server-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![GNU Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## Overview
This repository contains the setup, scripts, telemetry logs, and analysis reports for **Lab 4: Exploring vmstat for Memory and CPU Insights**. The primary goal of this lab is to utilize the `vmstat` (Virtual Memory Statistics) utility to monitor system performance in real time, diagnose CPU bottlenecks, analyze virtual memory allocation and swap thrashing, and create automated monitoring dashboards for Red Hat Enterprise Linux / CentOS environments.

---

## Workspace Directory Structure

```text
04-exploring-vmstat-for-memory-and-cpu-insights/
├── memory_test.sh
├── swap_test.sh
├── memory_analysis.sh
├── cpu_test.sh
├── io_test.sh
├── cpu_analysis.sh
├── memory_trend.sh
├── system_baseline.sh
├── performance_simulator.sh
├── monitor_dashboard.sh
├── memory_trend.csv
└── screenshots/
    ├── vmstat-overview.png
    ├── memory-analysis.png
    ├── performance-simulator.png
    └── cpu-io-dashboard.png
```

---

## Tasks & Key Learnings

### Task 1: `vmstat` Field Architecture and Baseline Telemetry
* **Metrics Analyzed:**
  * **Procs:** `r` (runnable process queue length) and `b` (processes in uninterruptible sleep/waiting for I/O).
  * **Memory:** `swpd` (virtual memory used), `free` (idle RAM), `buff` (buffer cache), `cache` (page cache).
  * **Swap:** `si` (swap-in rate per sec), `so` (swap-out rate per sec).
  * **I/O:** `bi` (blocks received from block devices), `bo` (blocks sent to block devices).
  * **System:** `in` (interrupts per sec), `cs` (context switches per sec).
  * **CPU:** `us` (user space time), `sy` (kernel space time), `id` (idle time), `wa` (I/O wait time), `st` (hypervisor stolen time).
* **Execution:** Sampled interval metrics using `vmstat 2 10` to establish non-buffered continuous telemetry.

### Task 2: Virtual Memory & Swap Analysis
* **Automated Scripts:** Developed `memory_test.sh`, `swap_test.sh`, and `memory_analysis.sh`.
* **Telemetry Inspection:** Evaluated system memory usage through `/proc/meminfo` and `free -h`, isolating memory allocation trends across process tiers (`top -%mem`).

### Task 3: CPU Bottleneck & I/O Wait Diagnostics
* **Load Simulation:** Developed `cpu_test.sh` and `io_test.sh` to generate user-space calculation loops (`bc`) and write stress (`dd`).
* **Threshold Rules Established:**
  * **CPU Bottleneck:** `us + sy > 80%` with process queue `r > CPU count`.
  * **I/O Bottleneck:** `wa > 20%` with non-zero blocked processes (`b > 0`).

### Task 4: System Baselines & Real-Time Dashboarding
* **Baseline Generation:** Executed `system_baseline.sh` to create timestamped state baselines combining system specs, disk configurations, and multi-sample telemetry.
* **Live Dashboard:** Engineered `monitor_dashboard.sh` using `stdbuf -oL` line unbuffering to render color-coded real-time status alerts for CPU utilization, I/O wait, and process run queues.

---

## Execution Screenshots & Telemetry

### 1. `vmstat` Overview & Continuous Sampling
Shows memory trend sampling alongside real-time multi-interval `vmstat 2 10` execution.

![VMStat Overview](screenshots/vmstat-overview.png)

### 2. Automated Memory & Swap Analysis Report
Shows execution of `./memory_analysis.sh` providing memory breakdown, process memory usage sorting, and interval snapshots.

![Memory Analysis Report](screenshots/memory-analysis.png)

### 3. Workload Simulator Execution
Shows `./performance_simulator.sh` executing synthetic memory leaks, CPU spikes, and I/O bottlenecks.

![Performance Simulator](screenshots/performance-simulator.png)

### 4. Real-Time Performance Dashboard Alerting
Shows `monitor_dashboard.sh` capturing a synthetic CPU spike, raising real-time alerts for **HIGH USER CPU: 98%** and an **ELEVATED PROCESS QUEUE (r): 8**.

![CPU IO Dashboard](screenshots/cpu-io-dashboard.png)

---

## Conclusion
Through this lab, we established a robust framework for RHEL performance diagnostic workflows using `vmstat`. By pairing low-overhead kernel stats with automated Bash scripts, we successfully simulated real-world resource constraints, identified CPU and I/O bottlenecks, and built an unbuffered real-time terminal dashboard capable of detecting performance anomalies under heavy server loads.