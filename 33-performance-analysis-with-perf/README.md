# Lab 14: Performance Analysis with perf

<p align="left">
  <img src="https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat" />
  <img src="https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=white" alt="C" />
  <img src="https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash" />
</p>

An enterprise-grade performance profiling and system-tuning lab on CentOS Stream 9 / RHEL environments using the Linux kernel `perf` subsystem. This repository contains custom C workload applications, hardware performance monitoring routines, CPU profiling scripts, memory access pattern analyzers, block I/O tracing tools, and automated performance reporting engines.

---

## 📌 Executive Summary & Architecture

System performance analysis requires deep visibility into hardware counter events, instruction-per-cycle (IPC) efficiencies, cache-miss ratios, and kernel system call latencies. 

This lab establishes an automated diagnostic suite for:
1. **CPU Hotspot Analysis:** Utilizing `perf stat`, `perf record`, and real-time interactive sampling via `perf top` to identify hotspots at the function and instruction level.
2. **Memory Access Pattern Evaluation:** Measuring cache line utilization, Last Level Cache (LLC) load misses, page fault frequencies, and NUMA node locality.
3. **Storage & Filesystem Subsystem Diagnostics:** Tracing block layer requests (`block_rq_issue`) and file system operations using synthetic workload stress-testing with `dd` and custom C I/O buffers.
4. **Multi-Resource Profiling:** Executing concurrent multithreaded workloads (`POSIX threads`) across CPU, memory, and disk I/O, generating aggregate performance summaries.

---

## 🛠 Repository Structure

```text
33-performance-analysis-with-perf/
├── screenshots/
│   ├── 01_perf_top_live_cpu_profiling.png
│   └── 02_perf_stat_memory_and_cpu.png
└── scripts/
    ├── cpu_intensive.c             # High-frequency floating point compute workload
    ├── memory_test.c               # Sequential vs. random memory access patterns
    ├── io_test.c                   # File buffer read/write stress generator
    ├── comprehensive_test.c        # Multithreaded concurrent CPU/Memory/IO benchmark
    └── analyze_performance.sh      # Automated diagnostic summary reporter
```

---

## 🚀 Execution & Profiling Workflow

### Task 1: CPU Subsystem Profiling

#### 1. Compile Workload & Execute Performance Stat Counters
```bash
# Compile CPU intensive benchmark
gcc -o cpu_intensive cpu_intensive.c

# Measure hardware performance counters
perf stat -e cycles,instructions,cache-references,cache-misses,branch-misses ./cpu_intensive
```

#### 2. Real-Time Interactive CPU Hotspot Tracing
```bash
# Run process in background
./cpu_intensive &
CPU_PID=$!

# Launch real-time CPU profiler
sudo perf top
```

![Live CPU Profiling with perf top](screenshots/01_perf_top_live_cpu_profiling.png)

---

### Task 2: Memory Access & NUMA Subsystem Analysis

#### 1. Memory Access Pattern Benchmark Execution
```bash
# Compile memory test program
gcc -o memory_test memory_test.c

# Analyze memory performance metrics
perf stat -e cache-misses,cache-references,LLC-loads,LLC-load-misses,page-faults ./memory_test
```

#### 2. Hardware Topology & Event Fallback Analysis
```bash
# Inspect NUMA topology
numactl --hardware

# Record memory events
sudo perf record -e cache-misses,cache-references,page-faults ./memory_test
sudo perf report --stdio > memory_analysis.txt
```

![Performance Stat and Memory Profiling Metrics](screenshots/02_perf_stat_memory_and_cpu.png)

---

### Task 3: Storage & Filesystem Subsystem Diagnostics

```bash
# Compile I/O workload generator
gcc -o io_test io_test.c

# Record file system operations and system calls
sudo perf record -e syscalls:sys_enter_write,syscalls:sys_enter_read ./io_test

# Trace block I/O requests on disk writes
sudo perf stat -e block:block_rq_issue,block:block_rq_complete dd if=/dev/zero of=large_test_file bs=1M count=100

# Cleanup temporary artifacts
rm -f large_test_file
```

---

### Task 4: Comprehensive Multi-Resource Analysis

#### 1. Multithreaded Application Profiling
```bash
# Compile pthread-enabled multi-resource benchmark
gcc -pthread -o comprehensive_test comprehensive_test.c

# Capture comprehensive system events
sudo perf record -g -e cycles,cache-misses,page-faults ./comprehensive_test
sudo perf report --stdio > comprehensive_analysis.txt
```

#### 2. Automated Performance Summary Engine
```bash
cat << 'EOF' > analyze_performance.sh
#!/bin/bash
echo "=== Performance Analysis Summary ==="
echo "1. CPU Performance: Check IPC ratios and hotspot symbols."
echo "2. Memory Performance: Evaluate cache misses and page faults."
echo "3. I/O Performance: Trace block-level latencies."
echo "4. Recommendations:"
if [ -f comprehensive_analysis.txt ]; then
    grep -E "(overhead|symbol)" comprehensive_analysis.txt | head -10
fi
EOF

chmod +x analyze_performance.sh
./analyze_performance.sh
```

---

## 🎯 Key Performance Insights & Lessons Learned

1. **Hardware Counter Abstraction in Cloud Environments:** Standard hardware counters (`cache-misses`, `LLC-loads`) in hypervisor cloud instances may require fallback software tracepoints (`page-faults`, `syscalls`) due to virtualization restrictions on Performance Monitoring Units (PMUs).
2. **Real-time Sample Profiling (`perf top`):** Effectively isolated function call overheads down to specific functions (such as `main` consuming 88.79% during compute-heavy cycles), guiding targeted code optimizations.
3. **Sequential vs. Random Memory Locality:** Sequential memory traversals leverage processor pre-fetching, whereas random access patterns significantly increase memory controller access latency.

---

## 🏁 Conclusion

Through this lab, a complete performance diagnostic framework was established using Linux `perf`. By writing low-level C benchmarks and capturing kernel performance statistics across CPU compute loops, memory allocations, and storage I/O, we demonstrated how to diagnose bottlenecks, analyze runtime overheads, and optimize application efficiency on Enterprise Linux platforms.