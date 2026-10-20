# Red Hat Certified Specialist in Performance Tuning & Analysis

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Bash](https://img.shields.io/badge/Bash_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

Hands-on performance tuning, system monitoring, kernel optimization, and benchmark testing on Enterprise Linux (RHEL/CentOS) environments.

---

## 📌 Repository Overview

This repository documents automated tools, custom bash scripts, configuration files, and benchmark evaluations based on the **Red Hat Certified Specialist in Performance Tuning** curriculum. The objectives cover bottleneck detection, CPU scheduling priority adjustments, virtual memory parameter optimization, and storage I/O tuning.

---

## 📁 Repository Structure

```text
redhat-performance-tuning/
├── 01-performance-tuning/
│   ├── performance_baseline.sh
│   ├── detect_cpu_bottleneck.sh
│   ├── detect_memory_bottleneck.sh
│   ├── detect_disk_bottleneck.sh
│   ├── set_cpu_governor.sh
│   ├── optimize_disk.sh
│   ├── performance_test_suite.sh
│   └── performance_results/
├── LICENSE
└── README.md
```

---

## 🧪 Lab 1: Performance Tuning Concepts & Baseline Analysis

### **1. Environment Setup & Prerequisites**
To prepare the system for benchmarking and real-time metric capture, performance tools and stress-testing utilities were installed:

```bash
# Update system and install key diagnostic & stress suites
sudo dnf update -y
sudo dnf install -y htop iotop sysstat perf stress-ng kernel-tools bc

# Enable and start sysstat metric collector
sudo systemctl enable --now sysstat
```

---

### **2. System Baselines & Bottleneck Detection**

Automated monitoring scripts were developed to capture raw system state metrics and evaluate subsystems against performance thresholds.

#### **System Baseline Generation (`performance_baseline.sh`)**
Gathers high-level system architectural details, current load averages, memory allocations, and top resource-consuming processes into a unified report.

![System Baseline Output](https://via.placeholder.com/800x400.png?text=Placeholder:+Insert+Performance+Baseline+Output+Screenshot+Here)

#### **Subsystem Bottleneck Identification**
Custom detection logic compares live system metrics against specific thresholds:
* **CPU (`detect_cpu_bottleneck.sh`):** Evaluates 1-minute load average against total active CPU core counts (`nproc`).
* **Memory (`detect_memory_bottleneck.sh`):** Monitors RAM utilization percentage and swap space activation.
* **Disk I/O (`detect_disk_bottleneck.sh`):** Measures device I/O statistics and `%iowait` parameters via `iostat` and `sar`.

![Bottleneck Detection Results](https://via.placeholder.com/800x400.png?text=Placeholder:+Insert+Bottleneck+Detection+Scripts+Execution+Screenshot)

---

### **3. Subsystem Tuning Implementation**

#### **CPU Frequency & Priority Tuning**
* **Scaling Governor (`set_cpu_governor.sh`):** Checks `cpufreq` support and configures the system governor to `performance`.
* **Priority & Core Placement:** Uses `renice` to lower scheduling priority on CPU-bound processes (`stress-ng`) and `taskset` to bind processes to explicit CPU cores.

```bash
# Adjust process priority (nice value) and restrict CPU core affinity
sudo renice +10 -p <PID>
sudo taskset -cp 0 <PID>
```

![Process Priority and Affinity Verification](https://via.placeholder.com/800x400.png?text=Placeholder:+Insert+Renice+and+Taskset+Verification+Screenshot)

#### **Virtual Memory Parameter Optimization**
Persistent memory parameters were defined under `/etc/sysctl.d/99-memory-tuning.conf` to minimize swap churn and improve writeback efficiency:

```ini
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
vm.overcommit_memory = 0
vm.overcommit_ratio = 50
```

![Virtual Memory Settings Applied](https://via.placeholder.com/800x400.png?text=Placeholder:+Insert+sysctl+Execution+Verification+Screenshot)

#### **Storage I/O Optimization (`optimize_disk.sh`)**
Detects attached block devices (`sd*`, `nvme*`, `vd*`) and updates read-ahead parameters (`128KB`) while assigning efficient multi-queue I/O schedulers (`mq-deadline` / `none`).

---

### **4. Automated Stress Suite & Benchmark Summary**

The comprehensive testing framework (`performance_test_suite.sh`) applies synthetic stress loads across CPU, Memory, and Disk subsystems while capturing timestamped historical data into `performance_results/`.

```bash
# Execute automated performance test suite
~/01-performance-tuning/performance_test_suite.sh
```

![Benchmark Test Execution](https://via.placeholder.com/800x400.png?text=Placeholder:+Insert+Performance+Test+Suite+Summary+Screenshot)

---

## 🎯 Conclusion

Through structured baseline data gathering, automated script-based detection, and kernel-level tuning, this lab demonstrates effective system optimization strategies on Enterprise Linux systems:

1. **Proactive Monitoring:** Baseline scripting provides quantifiable metrics to distinguish normal operational load from system bottlenecks.
2. **Resource Allocation Control:** Modifying process priorities (`renice`) and CPU affinity (`taskset`) prevents background tasks from starving critical applications.
3. **Subsystem Optimization:** Fine-tuning kernel memory limits (`sysctl`) and block device settings (`read_ahead_kb`) reduces unnecessary latency during high workload peaks.
