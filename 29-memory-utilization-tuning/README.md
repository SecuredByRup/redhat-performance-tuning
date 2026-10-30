# Lab 9: Memory Utilization Tuning

<p align="left">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux Logo" />
  <img src="https://img.shields.io/badge/CentOS-00224C?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS Logo" />
  <img src="https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat Logo" />
  <img src="https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS Logo" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash Logo" />
</p>

## Executive Summary

This project demonstrates advanced Linux memory management, kernel tuning, and subsystem optimization on an enterprise Red Hat / CentOS 8 environment running on AWS EC2. The primary objective is to optimize virtual memory paging, refine swap aggressiveness (`vm.swappiness`), manage directory entry caching (`vfs_cache_pressure`), and enforce dirty memory writeback ratios (`vm.dirty_ratio`) to maximize overall system throughput and mitigate potential performance bottlenecks.

Through practical scripting and real-time performance stress testing using `stress-ng` and `vmstat`, kernel performance parameters were systematically evaluated and dynamically configured for high-memory production workloads.

---

## Objectives & Key Highlights

* **Kernel Parameter Tuning:** Modified and persisted `vm.swappiness`, `vm.vfs_cache_pressure`, `vm.dirty_ratio`, and `vm.dirty_background_ratio`.
* **Memory Subsystem Inspection:** Analyzed physical and virtual memory allocation using `/proc/meminfo`, `free`, and `/proc/sys/vm/` endpoints.
* **Real-time Performance Monitoring:** Monitored memory page paging (`si`/`so`), block I/O (`bi`/`bo`), and process context switches (`cs`) using `vmstat`.
* **Load Testing & Bottleneck Analysis:** Created stress scenarios with `stress-ng` to observe system behavior under high RAM pressure.
* **Automated Sizing Logic:** Developed intelligent Bash automation scripts to detect physical host RAM sizes (e.g., 15 GiB) and automatically calculate optimal sysctl parameters.

---

## Technical Architecture & Prerequisites

| Requirement / Spec | Details |
| :--- | :--- |
| **Operating System** | CentOS Linux 8 / RHEL 8 (Kernel 4.x/5.x) |
| **Cloud Environment** | AWS EC2 (x86_64 Architecture) |
| **Installed RAM** | 15 GiB Total Memory |
| **Key Utilities Used** | `sysctl`, `free`, `vmstat`, `stress-ng`, `awk`, `bash` |
| **Access Rights** | Standard user (`centos`) with `sudo` escalation |

---

## Implementation & Hands-on Workflows

### Task 1: Examining Memory Baseline & Initial Tuning

The memory configuration was inspected to evaluate baseline RAM allocations and kernel default values (`swappiness=60`). A script (`memory_tune.sh`) was written and executed to apply low-latency memory defaults:

```bash
# Capture memory baseline
cat memory_baseline.txt

# Execute initial memory tuning script
./memory_tune.sh
```

**Key Parameters Applied:**
* `vm.swappiness=10`: Reduces kernel aggressive swapping to disk, favoring RAM retention.
* `vm.vfs_cache_pressure=50`: Retains directory and inode caches longer in memory.
* `vm.dirty_ratio=15` & `vm.dirty_background_ratio=5`: Accelerates dirty page flush to disk.

Next, `explain_free.sh` was executed to break down the differences between raw **`free`** RAM and **`available`** RAM (accounting for active buffers and caches).

![Baseline, Swappiness Tuning, and Free Metrics Breakdown](01-memory-baseline-tuning-free.png)

*Figure 1: Displays initial memory baseline report, immediate `sysctl` kernel parameter application via `memory_tune.sh`, and detailed RAM breakdown via `explain_free.sh`.*

---

### Task 2: Advanced Monitoring & System Diagnostics

Real-time virtual memory performance statistics were collected using `vmstat 2 5` to analyze system behavior under idle and active conditions.

When executing initial system modifications via standard user privileges, permission errors were captured due to kernel security protections on specific `/proc` and `/etc/sysctl.conf` write calls.

```bash
# Observe virtual memory statistics (2-second interval, 5 samples)
vmstat 2 5

# Execute custom memory optimization script
./optimize_memory.sh
```

![Virtual Memory Statistics and Security Privilege Diagnostics](02-vmstat-and-permission-troubleshooting.png)

*Figure 2: Real-time `vmstat` output showing process sleep queues, block I/O, and permission handling diagnostics during unprivileged `sysctl` modifications.*

---

### Task 3: Load Testing & Enterprise Memory Optimization

To validate system performance under actual memory contention, `memory_performance_test.sh` was executed. The suite utilized `stress-ng` to allocate 256 MiB memory stress workers across virtual memory pages.

Following the stress test, the optimization script was run with root privileges (`sudo ./optimize_memory.sh`). The script dynamically detected the host’s **15 GiB RAM** capacity, categorized it as a **High-Memory System**, and applied high-performance production parameters:

```bash
# Execute stress test suite
./memory_performance_test.sh

# Monitor system state during stress test
vmstat 2 5

# Apply persistent high-memory kernel optimizations with sudo
sudo ./optimize_memory.sh
```

**Applied Production Configuration (`/etc/sysctl.conf`):**
* `vm.swappiness=1`: Minimizes swap utilization completely unless under extreme emergency paging pressure.
* `vm.vfs_cache_pressure=50`: Optimizes file system metadata caching.
* `vm.dirty_ratio=10`: Caps maximum unwritten dirty pages at 10% of total RAM.
* `vm.dirty_background_ratio=3`: Background writeback starts proactively at 3% dirty RAM.
* `vm.dirty_expire_centisecs=3000` & `vm.dirty_writeback_centisecs=500`: Controls flush frequency.

![Stress Testing and High-Memory Optimization Execution](03-stress-testing-and-root-optimization.png)

*Figure 3: Successful `stress-ng` load test execution, post-stress `vmstat` verification, and automated high-memory enterprise profile application via `sudo ./optimize_memory.sh`.*

---

## Verification & Key Results

1. **Persistent Configuration:** Confirmed settings were successfully committed to `/etc/sysctl.conf` via `grep swappiness /etc/sysctl.conf`.
2. **Swap Activity Optimization:** During memory stress tests, swap-in (`si`) and swap-out (`so`) rates remained at `0 KB/s`, eliminating unnecessary disk I/O latency.
3. **Cache Efficiency:** Retained approximately `13-14 GiB` of usable memory headroom under peak workloads.

---

## Conclusion

By tuning Linux virtual memory subsystem parameters (`vm.swappiness`, `vm.vfs_cache_pressure`, and dirty ratios), the system was transformed from default settings to an enterprise-optimized high-performance profile. Reducing swappiness to `1` on a 15 GiB RAM host ensures maximum utilization of high-speed physical memory, eliminates unnecessary swap disk thrashing, and drastically improves workload responsiveness for high-throughput enterprise applications.