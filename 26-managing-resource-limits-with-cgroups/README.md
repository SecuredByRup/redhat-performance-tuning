# Lab 6: Managing Resource Limits with Control Groups (cgroups v2)

<p align="left">
  <img src="https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=red-hat&logoColor=white" alt="Red Hat" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS" />
  <img src="https://img.shields.io/badge/systemd-000000?style=for-the-badge&logo=systemd&logoColor=white" alt="systemd" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash" />
</p>

## Overview

This repository documents the implementation, fine-tuning, and monitoring of **Control Groups v2 (cgroups v2)** on Enterprise Linux. The objective of this lab is to manage multi-tenant system resource limits—restricting CPU utilization, hard/soft memory boundaries, and block device I/O bandwidth—to ensure process isolation and workload predictability under heavy system stress.

---

## Directory & File Structure

```text
redhat-performance-tuning/26-managing-resource-limits-with-cgroups/
├── configs/
│   └── lab6-cgroup.service       # Systemd unit for persistent cgroup setup
└── scripts/
    ├── cgroup_monitor.sh         # Real-time multi-resource monitoring dashboard
    ├── cgroup_troubleshoot.sh    # Verification and diagnostic script
    ├── cpu_stress.sh             # CPU-intensive calculation stress test
    ├── io_stress.sh              # Sequential block device I/O throughput test
    ├── memory_stress.py          # Python memory allocation stress test
    ├── mixed_workload.sh         # Multi-resource combined stress test
    ├── performance_comparison.sh # Benchmarking script (cgroup vs unconstrained)
    └── web_server_sim.py         # HTTP web server simulation script
```

---

## Implementation Summary

### 1. Unified Hierarchy & Controller Enablement
* Verified `cgroup2` unified filesystem hierarchy at `/sys/fs/cgroup`.
* Enabled `cpu`, `memory`, and `io` controllers dynamically via `/sys/fs/cgroup/cgroup.subtree_control`.
* Created dedicated control groups (`lab6_demo` and `webserver`).

### 2. CPU Management
* Assigned relative weights (`cpu.weight = 50`) for proportional sharing.
* Configured quota ceilings (`cpu.max = 50000 100000`) to enforce a strict 50% single-core limit.

### 3. Memory Boundaries
* Configured soft memory limit (`memory.high = 83886080` / 80MB) for aggressive page reclaim.
* Configured hard memory limit (`memory.max = 104857600` / 100MB) to protect against OOM events.

### 4. I/O Throttling
* Identified block device major:minor numbers (`259:1`).
* Enforced read and write limits (`io.max`) restricting throughput to prevent disk starvation.

### 5. Systemd Persistence
* Packaged cgroup creation and resource allocation into `/etc/systemd/system/lab6-cgroup.service` to ensure configurations persist automatically across host reboots.

---

## Verification & Screenshots

### 1. Active Workload Execution
The core laboratory scripts were populated and executed directly within the local repository path.

![Script Execution & Stress Tests](script_execution_and_stress.png)
*Figure 1: Script repository directory listing and execution of `mixed_workload.sh` and `cpu_stress.sh`.*

---

### 2. Live Resource Throttling Dashboard
Running `./cgroup_monitor.sh` provides real-time telemetry from `/sys/fs/cgroup/lab6_demo/`.

![cgroup Resource Monitor](cgroup_monitor_dashboard.png)
*Figure 2: Real-time dashboard output showing 1,079 CPU throttling events (`nr_throttled`) totaling over 50 seconds (`throttled_usec: 50190808`), confirming kernel enforcement of `cpu.max` limits.*

---

### 3. Systemd Persistence & Directory Architecture
Verification of persistent systemd service state alongside clean repository organization.

![Systemd Status and Repository Structure](systemd_status_and_tree.png)
*Figure 3: Active systemd unit status (`lab6-cgroup.service`), I/O stress benchmarking, and complete directory tree output.*

---

## Conclusion

Through this lab module, cgroups v2 proved to be an indispensable kernel mechanism for modern Linux performance tuning and container runtime management. By configuring quota limits, soft/hard memory watermarks, and I/O bandwidth controls, unstable or runaway applications can be contained effectively without jeopardizing overall system stability. Packaging these rules into systemd ensures deterministic, production-ready operational persistence.