# Lab 38: Performance Tuning for Containers

![Linux](https://img.shields.io/badge/OS-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-Enterprise%20Linux-EE0000?style=for-the-badge&logo=red-hat&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)

---

## **Overview**
This repository documents the completion of **Lab 38: Performance Tuning for Containers**. The project focuses on resource constraint governance, cgroups v2 kernel-level performance tuning, container I/O and CPU quota enforcement, and automated telemetry logging across both standalone Docker containers and single-node Kubernetes (`K3s`) cluster environments.

---

## **Environment & Architecture**
* **Operating System:** CentOS Stream 9 / RHEL cloud virtual machine instances running on AWS infrastructure.
* **Storage Architecture:** AWS NVMe root block devices (`/dev/nvme0n1`) for high-throughput block I/O validation.
* **Container Runtime:** Docker configured with the modern **systemd cgroup driver** (mapping containers directly to `/sys/fs/cgroup/system.slice/`).
* **Orchestration Layer:** Single-node K3s cluster with customized metrics-server configuration.

---

## **Repository Structure**

```text
38-performance-tuning-for-containers/
├── README.md                         # Lab documentation and execution summary
├── scripts/
│   ├── monitor_docker.sh             # Docker resource usage collector
│   ├── monitor_cpu_throttle.sh       # Cgroups v2 CPU quota and throttling monitor
│   ├── monitor_k8s.sh                # Kubernetes pod performance telemetry logger
│   ├── performance_monitor.sh        # Cluster-wide aggregate metrics monitor
│   ├── docker_performance.csv        # Exported Docker telemetry data
│   ├── cpu_throttle_performance.csv  # Exported CFS throttling metrics log
│   ├── k8s_performance.csv           # Exported Kubernetes pod telemetry
│   └── performance_report.csv        # Aggregate cluster resource performance report
└── assets/
    └── container-performance-telemetry-validation.png
```

---

## **Key Implementation Tasks**

### **1. Container Resource & I/O Governance**
* Configured strict memory limits (`--memory="256m"`, `--memory-swap="256m"`) effectively disabling swap partitions to bound container memory consumption.
* Enforced block I/O bandwidth limits targeting the AWS NVMe root disk (`/dev/nvme0n1`) using `--device-read-bps` and `--device-write-bps` parameters.

### **2. CPU Performance Tuning & Cgroups v2 CFS Quotas**
* Deployed CPU-bound workloads restricted via `--cpus="0.5"` to evaluate hard throttling.
* Inspected container runtime limits and telemetry directly from kernel cgroups v2 control files (`cpu.max` and `cpu.stat`):
  - `nr_periods`: Total elapsed scheduling periods.
  - `nr_throttled`: Frequency of container quota violations.
  - `throttled_usec`: Accumulated execution pause duration.

### **3. Kubernetes Resource Management & Telemetry**
* Implemented namespace-scoped `LimitRange` objects enforcing mandatory default requests and hard maximum/minimum container resource constraints.
* Developed automated monitoring scripts utilizing robust text processing (`tail -n +2`) to aggregate `kubectl top nodes` and `kubectl top pods` metrics into persistent CSV audit reports.

---

## **Execution Evidence & Validation**

The telemetry collection scripts successfully capture real-time CPU throttling counters, node utilization percentages, and pod distribution metrics into structured CSV audit logs.

![Container Performance Telemetry Validation](assets/container-performance-telemetry-validation.png)
*Figure: Live terminal execution showing successful `kubectl top` node/pod monitoring, cgroups v2 CFS throttling metrics from `cpu_throttle_performance.csv`, and aggregate cluster reports from `performance_report.csv`.*

---

## **Author**
* **SecuredByRup**
* **Email:** `cloudarchitectrup@gmail.com`