# Lab 39: Comprehensive Performance Review

<p align="left">
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="RHEL" />
  <img src="https://img.shields.io/badge/CentOS_Stream-26252D?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/Bash_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash" />
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" alt="Git" />
</p>

---

## Overview

**Lab 39: Comprehensive Performance Review** provides an end-to-end hands-on methodology for identifying performance bottlenecks, executing targeted kernel tuning, and validating system resource changes under sustained workloads on enterprise Linux systems (RHEL/CentOS).

The primary objectives of this lab include:
* **System Baseline Profiling**: Capturing detailed hardware specifications and initial operational metrics.
* **Telemetry & Load Generation**: Concurrently running custom workload generators (CPU stress and disk I/O) while sampling system performance via native Linux tools (`top`, `iostat`, `sar`, `vmstat`).
* **Bottleneck Analysis**: Evaluating resource usage against critical operational thresholds to isolate bottlenecks.
* **Targeted Kernel Optimization**: Adjusting virtual memory parameters, disk I/O queue schedulers, and TCP socket buffer allocations.
* **Comparative Audit & Verification**: Conducting post-tuning workload tests to measure exact performance deltas and persisting configurations via `sysctl.d`.

---

## Repo Structure

All scripts, telemetry logs, reports, and asset images are organized within a dedicated, self-contained repository structure:

```text
39-comprehensive-performance-review/
├── 01_system_baseline_and_analysis.png              # Screenshot: System baseline & performance analysis
├── 02_kernel_tuning_and_performance_comparison.png # Screenshot: Applied kernel tuning & comparative audit
├── baseline/                                        # Hardware and system specification logs
│   └── system_info.txt
├── monitoring/                                      # Raw telemetry logs collected during stress runs
│   └── LATEST                                       # Directory pointer to the latest monitoring run
├── post_tuning/                                     # Telemetry logs collected post-optimization
│   └── LATEST                                       # Directory pointer to the latest post-tuning run
├── reports/                                         # Generated performance analysis & comparison reports
└── scripts/                                         # Custom Bash automation scripts
    ├── analyze_performance.sh
    ├── apply_tuning.sh
    ├── build_summary.sh
    ├── compare_performance.sh
    ├── current_tunables.sh
    ├── generate_load.sh
    ├── performance_monitor.sh
    └── post_tuning_test.sh
```

---

## Implementation and Execution Details

The implementation follows a modular workflow driven by automated Bash scripts residing in the `scripts/` directory:

### Step 1: Baseline Collection & Telemetry
1. **`baseline/system_info.txt` Generation**: Captured host hardware information including CPU model (`AMD EPYC 7571`), core count (4 cores), memory limits, kernel version (`5.14.0-654.el9.x86_64`), and uptime.
2. **Workload Generation (`scripts/generate_load.sh`)**: Initiates concurrent multi-core prime factor computations (`factor`) alongside iterative 80MB file writes and reads using `dd` to simulate realistic system stress over a 120-second window.
3. **Continuous Monitoring (`scripts/performance_monitor.sh`)**: Collects real-time telemetry at 2-second intervals using `top`, `iostat`, `sar`, and `vmstat`, logging outputs into timestamped subdirectories under `monitoring/`.

### Step 2: Analysis & Tunable Inspection
1. **Automated Parsing (`scripts/analyze_performance.sh`)**: Aggregates raw metrics to calculate average CPU busy percentage, memory utilization, and disk I/O utilization.
2. **System Inspection (`scripts/current_tunables.sh`)**: Queries active kernel parameters across virtual memory (`vm.swappiness`, `vm.dirty_ratio`), network buffers (`net.core.rmem_max`, `net.core.wmem_max`), and active block device I/O schedulers.

### Step 3: Kernel Tuning & Validation
1. **Tuning Application (`scripts/apply_tuning.sh`)**:
   * **Virtual Memory**: Set `vm.swappiness = 10`, `vm.dirty_ratio = 15`, and `vm.dirty_background_ratio = 5` to optimize memory retention and page flushing.
   * **Network Buffers**: Elevated max read/write socket memory limits (`rmem_max` & `wmem_max`) to `16777216` bytes (16MB) and enabled TCP window scaling.
   * **Disk I/O Schedulers**: Configured optimal queue schedulers based on disk type (`none`/`mq-deadline`).
   * **Persistence**: Wrote permanent configuration entries to `/etc/sysctl.d/99-performance-tuning.conf`.
2. **Post-Tuning Test & Delta Computation (`scripts/post_tuning_test.sh` & `scripts/compare_performance.sh`)**: Executed an identical 120-second load test, captured post-tuning telemetry into `post_tuning/`, and computed side-by-side metric deltas.
3. **Audit Assembly (`scripts/build_summary.sh`)**: Consolidated baseline analysis and before/after comparisons into a single report in `reports/`.

---

## Visual Verification and Screenshots

To maintain repository cleanliness and clear visual presentation, the raw terminal execution screenshots were renamed as follows:

| Original Filename | Renamed Portfolio Asset | Context & Command Output |
| :--- | :--- | :--- |
| `Screenshot (755).png` | `01_system_baseline_and_analysis.png` | System hardware verification (`cat baseline/system_info.txt`), workload execution (`generate_load.sh`), and baseline analysis report generation (`analyze_performance.sh`). |
| `Screenshot (756).png` | `02_kernel_tuning_and_performance_comparison.png` | Privilege escalation and tuning application (`sudo apply_tuning.sh`), post-tuning workload run (`post_tuning_test.sh`), and final performance comparison report (`compare_performance.sh`). |

### Execution Screenshots

#### 1. System Baseline & Bottleneck Analysis
![System Baseline and Analysis Output](01_system_baseline_and_analysis.png)
*Figure 1: Terminal capture showing system hardware identification (`AMD EPYC 7571`, 4 Cores, 1290 MB RAM), 120-second load generation, and baseline metric analysis execution.*

#### 2. Kernel Tuning Application & Performance Comparison
![Kernel Tuning and Comparison Output](02_kernel_tuning_and_performance_comparison.png)
*Figure 2: Terminal capture showing backup creation, sysctl tuning application, post-tuning workload verification, and side-by-side comparative metric audit.*

---

## Conclusion

**Lab 39** demonstrated a robust, data-driven approach to Linux performance engineering and kernel optimization. By combining automated monitoring pipelines with controlled stress generation, the lab verified that system performance can be quantitatively measured, adjusted, and validated.

Key takeaways include:
1. **Empirical Optimization**: Performance decisions must be backed by continuous sampling across CPU, memory, disk I/O, and network subsystems rather than static assumptions.
2. **Controlled Kernel Parameter Adjustment**: Tuning virtual memory ratios (`swappiness`, `dirty_ratio`) and socket memory limits effectively conditions system responsiveness under concurrent workload stress.
3. **Persistence and Auditability**: Writing persistent configurations to `/etc/sysctl.d/` ensures operational stability across system reboots, while structured comparison reports provide transparent evidence of optimization impact.