# Lab 13: Tuning Virtualization Performance

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![KVM](https://img.shields.io/badge/KVM-Hypervisor-FF6600?style=for-the-badge&logo=linux&logoColor=white)
![QEMU](https://img.shields.io/badge/QEMU-Emulation-FF0000?style=for-the-badge&logo=qemu&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-7%2F8-262577?style=for-the-badge&logo=centos&logoColor=white)
![Bash Shell](https://img.shields.io/badge/Shell_Scripting-Automation-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

An end-to-end performance tuning and automation lab for KVM/QEMU virtual machines on Enterprise Linux environments. This repository demonstrates vCPU topology optimization, NUMA node binding, Huge Pages allocation, dynamic VirtIO memory ballooning, automated load-balancing via cron, and benchmark stress-testing.

---

## 📌 Project Overview

Optimizing hypervisor and virtual machine (VM) performance requires fine-grained control over system resources. This project sets up an automated framework on CentOS/RHEL to:

1. **Configure vCPU Pinning & Topology:** Align virtual CPUs with physical host execution units to reduce cache misses and context switching overhead.
2. **Leverage Memory Tuning & NUMA:** Pin guest memory allocations strictly to host NUMA node `0` and configure Huge Pages (`hugetlbfs`) for lower TLB overhead.
3. **Implement Dynamic VirtIO Memory Ballooning:** Enable live memory reclamation and dynamic allocation adjustments between guest and host without requiring domain restarts.
4. **Automate Memory Balancing:** Deploy shell scripts and cron jobs to monitor host/guest memory pressure and reallocate RAM on the fly.
5. **Validate with Stress Benchmarks:** Measure system stability and performance under heavy load using `stress-ng`, `sysbench`, and `fio`.

---

## 🛠 Repository Structure

```text
32-tuning-virtualization-performance/
├── screenshots/
│   ├── 01_vm_status_and_hugepages.png
│   ├── 02_xml_cpu_numa_pinning.png
│   ├── 03_xml_virtio_ballooning.png
│   ├── 04_cpu_stress_test_execution.png
│   └── 05_memory_balloon_monitoring_and_stress.png
└── scripts/
    ├── balloon_config.xml           # VirtIO balloon device XML template
    ├── update_vm_memory.sh          # Injects HugePages and NUMA settings into VM XML
    ├── setup_ballooning.sh          # Configures memory ballooning device
    ├── update_vm_balloon.sh         # Directly modifies domain XML for VirtIO ballooning
    ├── monitor_balloon.sh           # Monitors live VM and host memory ballooning metrics
    ├── adjust_memory.sh             # Manual live memory allocation script
    ├── auto_balance.sh              # Intelligent automated memory balancing script
    ├── install_perf_tools.sh        # Automated tool deployment script (stress-ng, sysbench, fio)
    ├── cpu_stress_test.sh           # CPU load generator and domstats monitor
    ├── analyze_cpu_results.sh       # Aggregates CPU benchmark statistics
    ├── memory_stress_test.sh        # Memory load generator and dommemstat monitor
    ├── analyze_memory_results.sh    # Aggregates memory stress-testing metrics
    ├── comprehensive_benchmark.sh   # Full system benchmark engine (Sysbench & FIO)
    └── generate_report.sh           # Markdown lab report generation script
```

---

## 🚀 Step-by-Step Implementation & Technical Verification

### 1. VM Provisioning, vCPU Pinning, and Huge Pages Setup

The virtual machine `performance-vm` was configured with static CPU affinity (`vcpupin`) matching vCPU IDs to host physical cores `0-3`. Host memory was allocated with 1024 Huge Pages ($2\text{MB}$ each, total $2048\text{MB}$ allocated).

![VM Status and HugePages Allocation](screenshots/01_vm_status_and_hugepages.png)

### 2. XML Domain Optimization (CPU & NUMA Binding)

To maximize memory access efficiency across sockets, guest RAM allocation was strictly bound to NUMA node `0` using `<numatune>` with `mode='strict'`. vCPU topologies were defined to match physical core layouts ($1$ socket, $4$ cores, $1$ thread).

![CPU and NUMA Pinning XML](screenshots/02_xml_cpu_numa_pinning.png)

### 3. Dynamic VirtIO Memory Ballooning Configuration

A VirtIO memory balloon device (`<memballoon model='virtio'>`) was added to the guest configuration with a polling period of $10\text{ seconds}$ (`<stats period='10'/>`) to collect real-time memory pressure metrics from inside the guest OS.

![VirtIO Memory Ballooning XML](screenshots/03_xml_virtio_ballooning.png)

### 4. Automated Memory Balancing & Cron Integration

An automated memory balancer (`auto_balance.sh`) was scheduled to run every $5\text{ minutes}$ via `crontab`. The script dynamically adjusts balloon sizes based on host memory threshold rules. CPU performance testing was executed and logged via `stress-ng`.

![Cron Scheduling and CPU Stress Test](screenshots/04_cpu_stress_test_execution.png)

### 5. Memory Stress Testing & Balloon Validation

The memory subsystem was tested under synthetic load using `stress-ng --vm 1 --vm-bytes 512M`. Live balloon statistics were continuously monitored via `monitor_balloon.sh` and `virsh dommemstat`.

![Memory Balloon Monitoring and Stress Testing](screenshots/05_memory_balloon_monitoring_and_stress.png)

---

## 📊 Summary of Optimization Results

| Optimization Layer | Applied Configuration | Observed Benefit / Performance Impact |
| :--- | :--- | :--- |
| **vCPU Tuning** | `<vcpupin>` 1:1 core mapping | Reduced inter-core context switches and scheduling latency. |
| **NUMA Memory** | Node 0 binding (`mode='strict'`) | Eliminated cross-socket memory access latencies. |
| **Huge Pages** | $1024 \times 2\text{MB}$ `hugetlbfs` pages | Reduced TLB miss rates during high memory throughput workloads. |
| **Memory Ballooning** | `virtio-balloon` with cron automation | Enables dynamic host RAM recovery without shutting down instances. |

---

## 🏁 Conclusion

Through targeted virtualization tuning and shell script automation, `performance-vm` was successfully optimized for high-density enterprise workloads. Configuring explicit vCPU affinity, host NUMA node alignment, and dynamic VirtIO memory ballooning provides optimal compute performance while maintaining dynamic resource flexibility across the hypervisor.