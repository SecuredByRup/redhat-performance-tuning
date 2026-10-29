# Advanced Performance Tuning with Blktrace

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Red Hat](https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

An end-to-end Linux block layer I/O tracing and performance tuning project. This repository documents low-level block tracing, queue depth tuning, I/O scheduler benchmarking, and aggregate latency reduction analysis using `blktrace`, `blkparse`, and `btt`.

---

## 🛠️ Technology Stack & Tools Used

* **Operating System:** RHEL / CentOS Enterprise Linux
* **Block Tracing & Analysis Tools:** `blktrace`, `blkparse`, `btt` (Block Trace Toolkit)
* **Storage Systems:** Linux Block Layer (`debugfs`, `/sys/block/<dev>/queue/`)
* **Benchmarking Utilities:** `dd`, `sysstat` (`iostat`), `iotop`

---

## 📌 Executive Summary & Key Results

By capturing low-level block device activity on an unpartitioned secondary NVMe device (`nvme1n1`), analyzing request queue stage latencies, and systematically sweeping multi-queue schedulers and queue parameters, the system achieved a measurable reduction in total Queue-to-Completion ($Q2C$) latency.

| Performance Metric | Baseline Configuration | Optimized / Tuned Configuration | Improvement |
| :--- | :--- | :--- | :--- |
| **I/O Scheduler** | `none` (Default) | `mq-deadline` | Optimized queue prioritization |
| **Read-Ahead (`read_ahead_kb`)** | $128 \text{ KB}$ | $2048 \text{ KB}$ | High sequential read throughput |
| **Max Throughput (Seq Read)** | $\sim 678 \text{ MB/s}$ | **$1331.2 \text{ MB/s}$** | **$+96.3\%$ Speedup** |
| **Average $Q2C$ Latency** | $0.001599890 \text{ s}$ ($\sim 1.60 \text{ ms}$) | **$0.001057792 \text{ s}$** ($\sim 1.05 \text{ ms}$) | **$\sim 33.9\%$ Latency Reduction** |

---

## 📂 Project Structure

```text
34-advanced-performance-tuning-using-blktrace/
└── scripts/
    ├── available_schedulers.txt      # Kernel-supported scheduler list
    ├── scheduler_results.csv         # Throughput benchmarks across schedulers
    ├── queue_tuning_results.csv     # Matrix sweep (nr_requests vs read_ahead_kb)
    ├── btt_summary.txt              # Baseline aggregate latencies
    ├── btt_summary_tuned.txt        # Post-tuning aggregate latencies
    ├── trace_mixed_parsed.txt       # Parsed human-readable trace stream (Baseline)
    └── trace_tuned_parsed.txt       # Parsed human-readable trace stream (Tuned)
```

---

## ⚙️ Step-by-Step Implementation

### Phase 1: Storage Setup & Baseline Trace Capture

1. **Environment Preparation:**
   * Mounted kernel `debugfs` at `/sys/kernel/debug`.
   * Formatted and mounted the secondary NVMe target (`/dev/nvme1n1`) at `/mnt/nvme-lab` to isolate I/O activity from the primary root OS disk.

2. **Workload & Baseline Tracing:**
   * Executed a background `blktrace` process targeting `nvme1n1` with explicit action masks (`queue`, `issue`, `complete`).
   * Generated a realistic mixed workload (sequential write, sequential read, and random $4\text{ KB}$ reads).
   * Processed binary trace files into a unified binary dump (`trace_mixed.bin`) and generated the baseline `btt` summary.

```bash
# Combine per-CPU binary files and generate btt report
blkparse -i trace_mixed -d trace_mixed.bin -o trace_mixed_parsed.txt
btt -i trace_mixed.bin > btt_summary.txt 2>&1
```

---

### Phase 2: System Verification & Baseline Latency

Verification of environment setup, per-CPU trace capture file creation, and baseline $Q2C$ latency analysis.

![Environment Verification and Baseline BTT](assets/01_environment_verification_and_baseline_btt.png)

* **Key Takeaway from Output:** The baseline $Q2C$ (Queue-to-Completion) average time across all block requests was **$0.001599890 \text{ s}$** ($\sim 1.60 \text{ ms}$).

---

### Phase 3: Benchmarking Schedulers & Parameter Sweeping

1. **Scheduler Discovery & Throughput Benchmarking:**
   Available multi-queue schedulers (`none`, `mq-deadline`, `kyber`, `bfq`) were dynamically discovered and evaluated under dropped VFS cache conditions (`echo 3 > /proc/sys/vm/drop_caches`).

2. **Queue Depth & Read-Ahead Matrix Sweep:**
   Swept permutations of `nr_requests` ($32, 128, 256$) and `read_ahead_kb` ($128, 512, 2048$) to identify throughput bottlenecks.

![Scheduler Benchmarks and Tuned BTT Comparison](assets/02_scheduler_benchmarks_and_tuned_btt_comparison.png)

* **Benchmarking Findings:**
  * Setting `read_ahead_kb` to **$2048 \text{ KB}$** doubled sequential read throughput from $594 \text{ MB/s}$ to **$1331.2 \text{ MB/s}$**.
  * `mq-deadline` showed superior request ordering over `none` under multi-threaded mixed read/write workloads.

---

### Phase 4: Validation & Post-Tuning Comparison

After applying optimal kernel block layer parameters (`BEST_SCHED="mq-deadline"`, `nr_requests=128`, `read_ahead_kb=2048`), the mixed workload trace was re-executed and parsed with `btt`:

```text
=== BASELINE Q2C (Default Settings) ===
Q2C      MIN: 0.001179056    AVG: 0.001599890    MAX: 0.001878901    N: 35

=== TUNED Q2C (Optimized Parameters) ===
Q2C      MIN: 0.000427685    AVG: 0.001057792    MAX: 0.003825014    N: 18
```

---

## 🎯 Conclusion

This project demonstrates a rigorous, data-driven approach to Linux storage performance engineering. Using `blktrace` and `btt`, kernel I/O request queue stages were dissected to diagnose bottlenecks. By tuning the Linux block layer queue depth and read-ahead settings based on workload characteristics:
1. **Queue-to-Completion ($Q2C$) latency dropped by over 33%**, significantly reducing I/O wait times.
2. **Sequential read throughput surged to over $1.3 \text{ GB/s}$**, demonstrating the power of precise storage stack optimization for enterprise workloads.