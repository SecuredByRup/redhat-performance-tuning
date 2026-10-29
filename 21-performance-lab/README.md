# Lab 1: Introduction to Performance Tuning Concepts

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat Enterprise Linux](https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=red-hat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Project Overview

This repository documents the practical execution of **Linux System Performance Tuning Fundamentals**. The objective of this lab is to explore baseline metrics, run synthetic workloads to measure throughput and response times, capture continuous system telemetry, detect resource bottlenecks, and evaluate scalability across CPU, Memory, and Disk I/O subsystems.

---

## 🎯 Lab Objectives

- Establish baseline system metrics for hardware and kernel resources.
- Differentiate between primary performance metrics: **Throughput**, **Response Time**, **Resource Utilization**, and **Scalability**.
- Monitor real-time performance indicators using open-source utilities (`top`, `free`, `df`, `iostat`, `uptime`).
- Simulate dynamic workloads to identify system bottlenecks.
- Measure scalability under increasing levels of concurrent resource stress.

---

## 🛠️ Environment & Tools

- **OS:** CentOS / RHEL (Kernel version `4.18.0-305.19.1.el8_4.x86_64`)
- **CPU:** AMD EPYC 7571 (4 vCPUs)
- **Memory:** 15 GiB RAM
- **Tools Used:** `bash`, `bc`, `sysstat` (`iostat`), `stress-ng`, `htop`, `top`

---

## 🚀 Execution & Implementation

### Phase 1: Workspace Setup & Baseline Collection

A dedicated workspace was initialized, and a baseline report script was run to capture system hardware parameters prior to load testing.

```bash
mkdir -p ~/performance_lab
cd ~/performance_lab
```

#### Output: System Baseline & Performance Demo

The script captured core counts, memory capacity, filesystem mount points, current load average, and measured baseline CPU calculation throughput alongside disk write response times.

![Baseline System Metrics and Performance Demo Execution](./01_baseline_and_performance_demo.png)

> **Renamed File:** `Screenshot (675).png` ➡️ `01_baseline_and_performance_demo.png`

---

### Phase 2: Performance Monitoring & Scalability Assessment

#### Monitoring & Bottleneck Detection
Continuous system sampling (`system_monitor.sh`) was executed for 60 seconds to capture periodic metrics. Following monitoring, the automated bottleneck analysis script (`analyze_bottlenecks.sh`) verified system health across CPU, Memory, and Storage usage.

#### Scalability Testing Framework
The scalability test evaluated the system's ability to handle parallel execution across three dimensions:
1. **CPU Scalability:** Executing parallel mathematical computations across 1, 2, and 4 concurrent tasks.
2. **Memory Allocation Scalability:** Allocating memory buffers of 10 MB, 50 MB, and 100 MB.
3. **Disk I/O Scalability:** Generating concurrent stream operations across 1, 5, and 10 processes.

![Monitoring, Bottleneck Analysis, and Scalability Test Results](./02_monitoring_bottleneck_and_scalability.png)

> **Renamed File:** `Screenshot (676).png` ➡️ `02_monitoring_bottleneck_and_scalability.png`

---

## 📊 Summary of Test Results

| Metric / Test | Observed Value / Duration | Status / Assessment |
| :--- | :--- | :--- |
| **CPU Throughput** | 400 calculations / sec | Baseline Normal |
| **Filesystem Response Time** | $\approx 0.016\text{s} - 0.018\text{s}$ per 10MB write | Stable |
| **CPU Usage (Idle)** | $1.5\%$ | ✅ Normal |
| **Memory Usage** | $6.31\%$ | ✅ Normal |
| **CPU Scalability (1 Core vs 4 Cores)** | $3\text{s}$ (1 task) $\rightarrow$ $4\text{s}$ (4 parallel tasks) | High Concurrency Efficiency |
| **Memory Scalability (100MB Allocation)** | $0.1035\text{s}$ | Excellent Memory Throughput |
| **Disk I/O Scalability (10 Concurrent Files)**| $< 1\text{s}$ total execution | High Disk Throughput |

---

## 💡 Key Tuning Recommendations

1. **CPU Management:** Utilize `nice` and `renice` to adjust process execution priorities. For critical latency-sensitive applications, set CPU affinity with `taskset`.
2. **Memory Management:** Fine-tune kernel swappiness (`vm.swappiness`) and dirty memory writeback ratios (`vm.dirty_ratio`) in `/etc/sysctl.conf`.
3. **Storage I/O:** Select appropriate I/O schedulers (`mq-deadline`, `bfq`, or `none` for NVMe/SSD drives) to optimize request queuing.

---

## 🏁 Conclusion

Through the systematic execution of benchmark scripts and automated telemetry collection, this lab successfully demonstrated fundamental Linux performance tuning concepts. By establishing baseline metrics prior to introducing synthetic load, we were able to evaluate resource utilization accurately and confirm system stability across scaling compute workloads. These monitoring and diagnostic practices form the baseline for continuous performance tuning and infrastructure optimization in enterprise Linux environments.