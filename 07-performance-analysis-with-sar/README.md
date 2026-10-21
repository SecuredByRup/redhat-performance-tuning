# Lab 7: Performance Analysis with `sar` (System Activity Reporter)

<p align="center">
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="RHEL Logo" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux Logo" />
  <img src="https://img.shields.io/badge/Bash_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash Logo" />
</p>

## Overview
This laboratory module focuses on automated system performance metrics collection, historical analysis, and alerting using the **System Activity Reporter (`sar`)** on Red Hat Enterprise Linux. System performance tuning requires granular, uninterrupted baseline tracking to isolate bottlenecks across CPU, memory, and storage subsystems.

Throughout this lab, automated `sar` metrics sampling was configured, multi-subsystem stress tests were executed, parsing scripts were written to identify utilization spikes, and a master consolidated report generator was built to categorize system health.

---

## Objectives
* Configure and enable persistent system data collection via `sysstat` and `sar`.
* Adjust data sampling frequencies and build custom enhanced data collection handlers.
* Analyze historical CPU metrics including `%user`, `%system`, `%iowait`, and `%idle`.
* Parse historical memory utilization metrics and identify memory starvation patterns.
* Evaluate block device I/O metrics including throughput ($TPS$) and percentage utilization (`%util`).
* Construct an automated system-wide health classifier and monitoring alert framework.

---

## Key Concepts & Architecture

| Component | Function | Key Metric / File |
| :--- | :--- | :--- |
| **`sysstat` Service** | Background collector (`sa1`) and binary logger (`sa2`) | `/etc/cron.d/sysstat`, `/var/log/sa/saXX` |
| **`sar -u`** | Captures CPU processor utilization and I/O waiting time | `%user`, `%system`, `%iowait`, `%idle` |
| **`sar -r`** | Captures active RAM allocation, cache, and buffer statistics | `kbmemfree`, `kbmemused`, `%memused`, `kbcached` |
| **`sar -d`** | Captures disk block device activity and I/O queue times | `tps`, `rkB/s`, `wkB/s`, `%util` |
| **Automated Monitoring** | Periodic cron job execution with threshold evaluation | `/usr/local/bin/automated_performance_monitor.sh` |

---

## Execution & Verification

### Task 1: Environment Setup & High-Frequency Data Collection
The `sysstat` tool suite was verified and the persistent collection interval was adjusted from 10 minutes down to 2 minutes in `/etc/cron.d/sysstat`. An enhanced collection script (`enhanced_sar_collection.sh`) was executed to capture detailed background samples.

![SAR Data Collection and Log Files](screenshots/01-sar-data-collection-and-logs.png)

*Figure 1: Real-time sampling with `sar -u 1 1`, log directory structure under `/var/log/sa/`, and initial report generation.*

---

### Task 2: CPU & Memory Performance Stress Testing
Load generation scripts (`cpu_stress_test.sh` and `memory_stress_test.sh`) were launched in background sessions to simulate sustained workload pressure. Historical log parser scripts (`analyze_cpu_performance.sh` and `analyze_memory_performance.sh`) were executed to filter data spikes exceeding critical thresholds.

![Memory Performance Analysis Report](screenshots/02-memory-performance-analysis-report.png)

*Figure 2: Memory performance report identifying period usage exceeding 80% allocation and calculated memory efficiency averages.*

---

### Task 3: Disk I/O Analysis & Master Consolidated Report
Block device stress testing was performed using synchronous `dd` operations (`disk_stress_test.sh`). The master performance analysis script (`master_performance_analysis.sh`) was created to parse all historical data files and synthesize CPU, memory, and disk utilization into system health categories (**GOOD**, **MODERATE**, or **HIGH**).

![Master Performance Report](screenshots/03-master-performance-report.png)

*Figure 3: Output of the consolidated master performance report showcasing overall CPU (15.36%), memory allocation summary, disk utilization (0.37%), and actionable tuning recommendations.*

---

## Automated Alerting Configuration
To ensure continuous monitoring beyond manual analysis, an automated cron job was deployed to run `/usr/local/bin/automated_performance_monitor.sh` every 30 minutes:

```bash
# Verify active cron entry for automated performance tracking
crontab -l | grep automated_performance_monitor
```

```text
*/30 * * * * /usr/local/bin/automated_performance_monitor.sh
```

---

## Conclusion
This lab demonstrated how `sar` and `sysstat` can be transformed from passive diagnostic utilities into an enterprise-grade automated monitoring and reporting pipeline. By writing custom parsing scripts, historical performance anomalies were isolated across CPU, RAM, and disk subsystems. Automating these evaluations with structured status classifications (**GOOD**, **MODERATE**, **HIGH**) equips Linux administrators with the baseline metrics needed for targeted kernel and resource optimization.