# Lab 12: Network Utilization Tuning & Performance Optimization

<p align="left">
  <img src="https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Systemd-111111?style=for-the-badge&logo=systemd&logoColor=white" alt="Systemd">
  <img src="https://img.shields.io/badge/Networking-007ACC?style=for-the-badge&logo=cisco&logoColor=white" alt="Networking">
</p>

---

## 📌 Executive Summary
This repository contains automated scripts, configuration templates, and benchmark logs for **Lab 12: Network Utilization Tuning**. Executed within a CentOS/RHEL 9 cloud environment (`5.14.0` kernel), this lab focuses on systematically diagnosing and eliminating network bottlenecks, optimizing TCP socket buffers using the Bandwidth-Delay Product (BDP), enabling the **BBR congestion control algorithm**, tuning NIC ring buffers and hardware offloads via `ethtool`, ensuring persistence through custom `systemd` services, and executing robust JSON-parsed performance comparisons with `iperf3` and `jq`.

---

## 🛠️ Environment & Tools
* **Operating System:** CentOS/RHEL 9 (Cloud Instance)
* **Primary Network Interface:** `ens5` (MTU 9001) / Local Loopback (`127.0.0.1`)
* **Core Utilities:** `iperf3`, `ethtool`, `sysstat` (`sar`), `jq`, `bc`, `systemd`

---

## 📂 Repository Structure
```text
31-network-utilization-tuning-lab/
├── scripts/
│   ├── baseline_config_capture.sh       # Captures initial interface & buffer state
│   ├── run_baseline_test.sh             # Executes baseline TCP/UDP/latency benchmarks
│   ├── calculate_buffers.sh             # Computes BDP and optimal socket buffer sizes
│   ├── network_optimization.conf        # Tuned sysctl parameters & BBR activation
│   ├── optimize_ring_buffers.sh         # Maximizes NIC RX/TX ring buffers
│   ├── optimize_offloads.sh             # Configures TSO, GSO, GRO, and checksumming
│   ├── optimize_coalescing.sh           # Configures adaptive interrupt coalescing
│   ├── comprehensive_test.sh            # Multi-stream & variable-window iperf3 suite
│   ├── performance_comparison.sh        # Automated jq-driven report generator
│   └── monitor_performance.sh           # SAR CPU and network error monitoring under load
└── results/
    ├── baseline_config.txt
    ├── baseline_results.json
    ├── tcp_optimized_results.json
    ├── comprehensive_results.json
    ├── performance_comparison.txt
    └── system_monitoring.txt
```

---

## 🚀 Step-by-Step Implementation

### Task 1: Baseline Network Performance Assessment
Initial system discovery verified the primary interface (`ens5`) and default kernel socket buffer configurations. Baseline throughput and latency metrics were captured into structured JSON files for reliable parsing.
* **Script:** `baseline_config_capture.sh` & `run_baseline_test.sh`

### Task 2: TCP Buffer Size Optimization & BBR Activation
Calculated optimal buffer sizing using the Bandwidth-Delay Product (BDP) formula and applied persistent kernel parameters under `/etc/sysctl.d/99-network-performance.conf`, enabling modern **BBR congestion control**.

![BDP Calculation and Multistream Test](01_bdp_calculation_and_multistream_iperf3.png)
*Figure 1: Executing BDP calculation script and running multi-stream `iperf3` tests.*

### Task 3: Network Interface Optimization & Persistence
Maximized hardware ring buffers, configured hardware offload features (TSO, GSO, GRO), and established adaptive interrupt coalescing. A custom `systemd` oneshot service (`network-optimization.service`) was created to ensure all `ethtool` settings automatically re-apply on system boot.

![Systemd Service Status](02_systemd_network_optimization_service_status.png)
*Figure 2: Verifying active status and successful execution of the persistent `network-optimization.service`.*

### Task 4: Comprehensive Testing, JSON Parsing & Resource Monitoring
Ran advanced multi-stream and variable-window test suites. Using `jq`, metrics were deterministically extracted from JSON outputs to generate a comparative performance report. System resource utilization and error metrics were monitored under heavy load using `sar`.

![TCP Optimized Test Execution](03_tcp_optimized_iperf3_execution.png)
*Figure 3: Executing optimized TCP buffer throughput tests with `iperf3`.*

![SAR System Monitoring](04_sar_system_performance_monitoring_execution.png)
*Figure 4: Capturing CPU usage and network interface statistics (`DEV`/`EDEV`) using `sar` during parallel throughput load.*

---

## 📊 Performance Analysis Summary
An excerpt from `results/performance_comparison.txt` highlights the programmatic comparison across tuning phases:

```text
=== Raw Throughput (bits per second) ===
Baseline:        941230000
TCP Optimized:   943850000
Fully Optimized: 945120000

=== Converted to Gbps ===
Baseline:        0.94 Gbps
TCP Optimized:   0.94 Gbps
Fully Optimized: 945120000 -> 0.94 Gbps

=== PERFORMANCE IMPROVEMENT ANALYSIS ===
Performance Improvement: .41%
```
*Note: On high-speed local loopback or saturated 1 Gbps LAN links, fractional percentage gains are expected because the link is already operating at line rate. Buffer and offload tuning provide exponential dividends on high-BDP (high bandwidth + high latency WAN) paths and multi-stream workloads.*

---

## 🎯 Conclusion
Through this lab, a comprehensive network tuning pipeline was successfully engineered and deployed on Red Hat Enterprise Linux. By combining programmatic BDP calculation, `sysctl` socket optimization, `ethtool` hardware tuning, `systemd` persistence, and robust JSON-based `jq` analytics, the infrastructure is fully hardened for high-throughput enterprise workloads, ensuring reproducible performance monitoring and automated regression detection over time.