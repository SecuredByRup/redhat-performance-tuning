# Red Hat Certified Specialist in Performance Tuning & Analysis

[![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)](https://www.redhat.com/)
[![CentOS](https://img.shields.io/badge/Cent%20OS-262577?style=for-the-badge&logo=centos&logoColor=white)](https://www.centos.org/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.kernel.org/)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

Hands-on performance tuning, system monitoring, kernel optimization, and baseline creation on Enterprise Linux (RHEL/CentOS) environments based on the **Red Hat Certified Specialist in Performance Tuning** curriculum.

---

## 📌 Repository Structure

```
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
├── 02-installing-monitoring-tools/
│   ├── vmstat_monitor.sh
│   ├── system_monitor.sh
│   ├── create_baseline.sh
│   ├── performance_analysis.sh
│   ├── performance_baseline/
│   └── screenshots/
│       ├── sysstat-iostat.png
│       └── performance-analysis.png
├── LICENSE
└── README.md
```

---

## 🧪 Lab 2: Installing Performance Monitoring Tools

### **Overview & Objectives**
* Install and verify core performance monitoring packages (`sysstat`, `htop`, `iotop`, `nethogs`, `bc`) on Red Hat Enterprise Linux.
* Enable and verify background data collection via `sysstat.service` to capture historical metrics (`sar`).
* Implement automated monitoring utilities and baseline collection scripts using Bash.
* Interpret disk I/O, CPU wait times, memory allocation, and kernel scheduling metrics to spot bottlenecks.

---

### **1. Package Installation & Service Activation**

Update package repositories and install primary system performance tools:

```bash
# Update repository index and install metric utilities
sudo dnf update -y
sudo dnf install -y sysstat htop iotop nethogs bc

# Enable and start continuous metric collection via sysstat service
sudo systemctl enable --now sysstat
```

---

### **2. Service Verification & Disk I/O Metrics**

Confirming that `sysstat.service` is active ensures continuous system activity accounting via `sa1` and `sa2` background processes. Extended disk device statistics are captured using `iostat -x`:

```bash
sudo systemctl status sysstat
iostat -x 1 3
```

![Sysstat Status & Extended I/O Statistics](02-installing-monitoring-tools/screenshots/sysstat-iostat.png)

---

### **3. Automated Diagnostic & Baseline Utilities**

Four custom Bash scripts were developed within `02-installing-monitoring-tools/`:

* **`vmstat_monitor.sh`**: Samples memory page-ins/outs, swap usage, and CPU context switches.
* **`system_monitor.sh`**: Produces log files summarizing CPU, memory, storage utilization, and top resource consumers.
* **`create_baseline.sh`**: Runs 60-second concurrent background samples using `sar` and `iostat` to establish system baselines.
* **`performance_analysis.sh`**: Evaluates system load against physical CPU core counts and calculates memory thresholds to output automated tuning recommendations.

---

### **4. Diagnostic Script Execution & Report Generation**

Running the comprehensive analysis tool evaluates current kernel states, memory bounds, and NVMe disk performance:

```bash
cd 02-installing-monitoring-tools
./performance_analysis.sh
```

![System Performance Analysis Report](02-installing-monitoring-tools/screenshots/performance-analysis.png)

---

## 🎯 Conclusion

In this lab, a complete performance monitoring infrastructure was initialized and validated on Enterprise Linux:

1. **Persistent Accounting**: Activating `sysstat` guarantees historical diagnostic metrics for retrospective incident analysis.
2. **Automated Baselining**: Custom Bash scripting facilitates continuous resource evaluation, identifying load anomalies before system degradation.
3. **Proactive Diagnostics**: Automated thresholds assist system administrators in pinpointing CPU queue backlogs and storage I/O bottlenecks efficiently.