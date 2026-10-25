# Lab 5: Analyzing Disk Performance with iostat

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-Enterprise%20Linux-CC0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS Stream](https://img.shields.io/badge/CentOS-Stream-26252D?style=for-the-badge&logo=centos&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Server-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## Overview
This directory contains the full documentation, diagnostic scripts, synthetic workload utilities, and optimization rules for **Lab 5: Analyzing Disk Performance with iostat**. The primary objective of this module is to perform real-time monitoring of Linux storage subsystems, analyze crucial I/O metrics (`%util`, `await`, `avgqu-sz`), trigger synthetic disk stress workloads, detect performance bottlenecks automatically, and evaluate/persist multi-queue I/O schedulers (`mq-deadline`, `kyber`, `bfq`, `none`).

---

## Directory Structure
```text
05-analyzing-disk-performance-with-iostat/
├── disk_monitor.sh
├── iostat_metrics_guide.txt
├── io_workload_generator.sh
├── bottleneck_analyzer.sh
├── baseline_measurement.sh
├── check_schedulers.sh
├── scheduler_guide.txt
├── scheduler_performance_test.sh
├── optimize_schedulers.sh
├── make_persistent.sh
├── validate_optimization.sh
└── screenshots/
    ├── iostat-overview.png
    └── bottleneck-analysis.png
```

---

## Lab Execution & Key Tasks

### Task 1: Monitoring Disk Performance with `iostat`
* Installed and configured the `sysstat` performance monitoring utility suite.
* Executed extended statistics monitoring using `iostat -x` to evaluate real-time metrics including read/write request rates (`r/s`, `w/s`), transfer throughput (`rkB/s`, `wkB/s`), average wait times (`await`, `r_await`, `w_await`), and overall disk utilization percentage (`%util`).
* Created `disk_monitor.sh` to capture timed performance logs in background background sessions.
* Authoritative key metrics guide compiled in `iostat_metrics_guide.txt`.

### Task 2: Workload Generation and Bottleneck Analysis
* Developed `io_workload_generator.sh` using `dd` and random seek offsets to generate controlled random read, sequential write, and combined mixed workloads.
* Programmed `bottleneck_analyzer.sh` to parse active I/O telemetry and flag devices exceeding critical performance thresholds:
  * High Utilization (`%util > 80%`)
  * Elevated Latency (`await > 20ms`)
  * Request Queue Buildup (`avgqu-sz > 2`)
* Created `baseline_measurement.sh` to document reference baseline metrics under both idle and stressed states.

### Task 3: I/O Scheduler Tuning and Persistence
* Developed `check_schedulers.sh` (updated to support modern cloud NVMe block devices `nvme0n1` and `nvme1n1`).
* Inspected active and available multi-queue kernel schedulers (`mq-deadline`, `kyber`, `bfq`, `none`).
* Evaluated scheduler characteristics: identified `none` as optimal for direct NVMe hardware queues and `mq-deadline` for traditional rotational storage.
* Automated persistent rule creation via `make_persistent.sh` writing custom `/etc/udev/rules.d/60-io-schedulers.rules`.

---

## Lab Screenshots & Validation

### 1. Real-Time Workload Generation & `iostat` Telemetry
Executing mixed random/sequential I/O workloads (`./io_workload_generator.sh mixed`) while continuously capturing extended disk statistics using `iostat -x 2`.

![Iostat Workload Telemetry](screenshots/iostat-overview.png)

---

### 2. Bottleneck Detection & Scheduler Inspection
Checking active multi-queue schedulers across system block devices (`nvme0n1`, `nvme1n1`) and executing automated bottleneck diagnostic reports via `./bottleneck_analyzer.sh`.

![Bottleneck Analysis and Schedulers](screenshots/bottleneck-analysis.png)

---

## Conclusion
Through this lab, comprehensive diagnostic and tuning methodologies were established for enterprise Linux storage subsystems. By combining real-time extended `iostat` monitoring, automated workload stress simulation, scriptable bottleneck detection, and persistent udev-based I/O scheduler optimization, storage bottlenecks can be proactively identified and mitigated to ensure low latency and high I/O throughput in high-performance cloud server environments.