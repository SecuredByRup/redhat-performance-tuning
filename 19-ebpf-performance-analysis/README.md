# Lab 19: Advanced Linux Performance Analysis with eBPF and BCC Tools

![eBPF](https://img.shields.io/badge/eBPF-Kernel_Tracing-blue?style=for-the-badge&logo=linux&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Red_Hat_/_CentOS_9-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Executive Overview

This lab demonstrates low-overhead, real-time Linux kernel performance monitoring and telemetry aggregation using **eBPF (Extended Berkeley Packet Filter)** and the **BCC (BPF Compiler Collection)** toolkit. 

Unlike traditional kernel module tracing (e.g., SystemTap) which relies on static kernel version matching (`vermagic`), eBPF compiles kernel instrumentation bytecode dynamically at runtime. This provides safety, performance, and immunity against minor kernel header and container version skew.

### Key Objectives
* **System Call Profiling**: Intercept and analyze system call distributions using `syscount`.
* **DNS Resolution Telemetry**: Capture user-space dynamic library calls (`getaddrinfo`) to measure DNS resolution latency using `gethostlatency`.
* **Automated Parser Development**: Build custom Python analyzers to convert raw trace logs into statistical distributions.
* **Unified Reporting**: Synthesize system metrics into a structured JSON report (`performance_report.json`) with automated issue identification and remediation recommendations.

---

## 🏗️ Architecture & Tooling

```
+------------------------------------------------------------------+
|                           User Space                             |
|  +--------------------+   +-------------------+  +------------+  |
|  | analyze_syscalls.py|   |analyze_dns_lat.py |  | Report Gen |  |
|  +---------^----------+   +---------^---------+  +-----^------+  |
|            |                        |                  |         |
|      syscount_output.txt      dns_latency.log   performance.json |
+------------|------------------------|------------------|---------+
|            | BCC Python Wrapper     | BCC Python Wrapper         |
+------------|------------------------|----------------------------+
|            | syscount               | gethostlatency             |
|            +-------------------+    +-----------------+          |
|                                |                      |          |
|                                v                      v          |
|                           [eBPF Bytecode Engine]                 |
+--------------------------------|---------------------------------+
|                                v                                 |
|                         Linux Kernel                             |
|                 (sys_enter / glibc tracepoints)                  |
+------------------------------------------------------------------+
```

---

## 🛠️ Environment Configuration & Kernel Header Workaround

When running on rolling CentOS/RHEL enterprise kernels, local kernel development packages (`kernel-devel`) may differ slightly from the running active kernel (`uname -r`). BCC requires kernel headers to compile eBPF programs on the fly via LLVM/Clang.

### Prerequisites Installation & Symlink Configuration
```bash
# 1. Install BCC tools and development headers
sudo dnf install -y bcc-tools kernel-devel python3-bcc bind-utils

# 2. Map running kernel path to available header directory
sudo mkdir -p /lib/modules/$(uname -r)
sudo rm -rf /lib/modules/$(uname -r)/build
sudo ln -sf /usr/src/kernels/$(ls /usr/src/kernels/ | head -n 1) /lib/modules/$(uname -r)/build
sudo touch /lib/modules/$(uname -r)/build/.config
```

---

## 🧪 Implementation & Verification

### Task 1: System Call Tracing (`syscount`)

To measure kernel call overhead, `syscount` attaches eBPF probes to the `raw_syscalls:sys_enter` tracepoint.

```bash
# Execute syscount for 20 seconds while triggering background workload
sudo /usr/share/bcc/tools/syscount -d 20 > syscount_output.txt &
SYSCOUNT_PID=$!

sleep 2
./test_workload.sh
wait $SYSCOUNT_PID

# Process telemetry with Python analyzer
python3 analyze_syscalls.py syscount_output.txt
```

#### Results & Output
The analysis identified high I/O operations (`close`, `read`, `write`, `fstat`) accounting for **49.44%** of all syscall execution during the test window.

![Syscall Analysis](./task1-syscall-analysis.png)

---

### Task 2: DNS Resolution Latency (`gethostlatency`)

`gethostlatency` attaches eBPF probes to `libc.so` functions (`getaddrinfo`, `gethostbyname`) to measure host resolution timing across processes.

> **Note on Python I/O Buffering**: Because BCC tools are Python scripts, stdout buffering must be bypassed using `python3 -u` when piping output to log files.

```bash
# Execute unbuffered gethostlatency trace
sudo python3 -u /usr/share/bcc/tools/gethostlatency > dns_latency.log 2>&1 &
GETHOSTLATENCY_PID=$!

sleep 2
./dns_test.sh

sleep 3
sudo kill "$GETHOSTLATENCY_PID" 2>/dev/null

# Parse DNS performance metrics
python3 analyze_dns_latency.py dns_latency.log
```

#### Results & Output
* **Total Resolutions**: 59 queries
* **Average Latency**: 1.88 ms
* **Median Latency**: 0.98 ms
* **Distribution**: 98.3% of queries completed within $<10\text{ ms}$.

![DNS Latency Analysis](./task2-dns-latency-analysis.png)

---

### Task 3: Consolidated Performance Reporting

Both monitoring tools were run concurrently during active workloads, feeding a unified Python report generator (`generate_performance_report.py`) that outputs structured JSON metadata.

```bash
# Run concurrent tracing
sudo /usr/share/bcc/tools/syscount -d 30 > syscount_output.txt &
SYSCOUNT_PID=$!

sudo python3 -u /usr/share/bcc/tools/gethostlatency > dns_latency.log 2>&1 &
GETHOSTLATENCY_PID=$!

sleep 2
./test_workload.sh
./dns_test.sh

wait $SYSCOUNT_PID
sudo kill "$GETHOSTLATENCY_PID" 2>/dev/null

# Generate JSON Report
python3 generate_performance_report.py syscount_output.txt dns_latency.log
python3 -m json.tool performance_report.json
```

#### Results & Output
![Performance Report JSON](./task3-performance-report-json.png)

---

## 📊 Summary Findings & Recommendations

1. **System Calls**: 44,524 total calls recorded over 30 seconds. Heavy file handle activity (`openat`: 7,421, `close`: 5,771).
2. **DNS Health**: Average latency of $1.97\text{ ms}$ with zero queries exceeding the $100\text{ ms}$ SLA threshold.
3. **Automated Recommendation**: I/O system call density was flagged for optimization (e.g., implementing application-level write buffering).

---

## 🎯 Conclusion

By utilizing **eBPF and BCC**, kernel and network performance telemetry can be extracted in real time with near-zero overhead. Building custom Python parsers allows complex kernel events to be transformed into actionable observability data and structured JSON reports suitable for SIEM integration, automated profiling pipelines, and enterprise performance tuning.