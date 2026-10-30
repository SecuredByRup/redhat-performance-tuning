# Red Hat Enterprise Linux Network Traffic Performance Tuning & Monitoring

![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Overview

This repository contains scripts and documentation for tuning, benchmarking, and monitoring network traffic performance on Enterprise Linux systems (RHEL/CentOS). The project focuses on optimizing TCP stack parameters (such as `sysctl` buffer tuning and TCP BBR congestion control algorithm), benchmarking network throughput using `iperf3`, inspecting active sockets and interface statistics, and tracking DNS resolution metrics.

---

## 🛠 Tech Stack & Tools

* **Operating System:** Red Hat Enterprise Linux / CentOS
* **Congestion Control Algorithms:** BBR, Cubic, Reno
* **Benchmarking & Analysis Tools:** `iperf3`, `sysctl`, `netstat`, `ss`, `systemd-resolved`
* **Automation:** Shell Scripting (`/bin/bash`)

---

## 📂 Repository Structure

```text
.
├── scripts/
│   ├── tcp_test.sh               # Runs TCP throughput benchmarking via iperf3
│   ├── network_monitor.sh        # Captures active connections, socket stats, and buffer usage
│   ├── dns_monitor.sh            # Monitors DNS resolution latency and cache statistics
│   ├── optimize_traffic.sh       # Applies sysctl network kernel tuning parameters
│   └── performance_validation.sh # Validates system-level network throughput and bounds
└── screenshots/
    ├── tcp-iperf3-throughput-test-part1.png
    ├── tcp-iperf3-throughput-test-part2.png
    ├── network-traffic-monitoring-report-part1.png
    ├── network-traffic-monitoring-report-part2.png
    └── dns-performance-monitoring-report.png
```

---

## 🚀 Execution & Performance Results

### 1. Kernel Parameter Inspection & TCP Performance Benchmarking

Before running network benchmarks, kernel memory limits (`net.core.rmem_max`, `net.core.wmem_max`) and available TCP congestion control modules (e.g., `bbr`, `cubic`, `reno`) are inspected using `sysctl`. 

Executing `./tcp_test.sh` initializes an `iperf3` server session in the background and runs parallel stream TCP throughput benchmarks.

![TCP Throughput Test Part 1](./screenshots/tcp-iperf3-throughput-test-part1.png)
*Figure 1: `tcp_test.sh` output displaying initial multi-stream TCP transfer rates (~14.8 to 15.8 Gbits/sec).*

![TCP Throughput Test Part 2](./screenshots/tcp-iperf3-throughput-test-part2.png)
*Figure 2: `tcp_test.sh` benchmark summary showing total bandwidth utilization of ~15.6 Gbits/sec across 18.2 GBytes transferred.*

---

### 2. Network Traffic & Socket State Monitoring

Running `./network_monitor.sh` provides an analysis of system-wide network sockets and transport layer statistics:
* Active TCP/UDP listening ports (`netstat` / `ss`)
* TCP connection states (ESTABLISHED, TIME-WAIT, CLOSE-WAIT)
* Network interface packet counters (`ens5`)
* TCP memory allocation and buffer headroom inspection

![Network Monitor Report Part 1](./screenshots/network-traffic-monitoring-report-part1.png)
*Figure 3: Detailed active connection breakdown and socket statistics across listening TCP/UDP services.*

![Network Monitor Report Part 2](./screenshots/network-traffic-monitoring-report-part2.png)
*Figure 4: TCP state summary, interface packet counters, and socket buffer usage metrics.*

---

### 3. DNS Performance & Cache Statistics

Executing `./dns_monitor.sh` checks resolution latency across public domain targets (e.g., Google, GitHub, Red Hat, StackOverflow) and evaluates local DNS caching effectiveness, DNSSEC support, and transaction counts.

![DNS Performance Monitoring](./screenshots/dns-performance-monitoring-report.png)
*Figure 5: DNS performance monitoring output displaying response times, cache hit/miss rates, and security verdicts.*

---

## 💡 Key Findings & Learnings

1. **Kernel Buffer Tuning:** Increasing `net.core.rmem_max` and `net.core.wmem_max` to `134217728` (128 MB) allows high-bandwidth local and long-fat networks (LFN) to maintain sustained throughput without dropping packets.
2. **TCP BBR Performance:** Enabling Google's BBR congestion control algorithm over traditional Loss-based algorithms (Cubic/Reno) significantly reduces retransmissions (`Retr: 0-4`) under high load.
3. **Socket Monitoring Efficiency:** Monitoring `ss` and `/proc/sys/net/ipv4/` metrics provides actionable visibility into socket memory leaks and buffer exhaustion bottlenecks.

---

## 🎯 Conclusion

This project demonstrates practical Linux network performance engineering and sysctl kernel parameter tuning. By automating performance benchmarks and real-time socket inspection through custom Bash scripts, enterprise Linux administrators can systematically diagnose latency bottlenecks, maximize bandwidth utilization, and optimize host network configurations for high-throughput environments.