# Analyzing System Performance Using `strace`

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat Enterprise Linux](https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![C](https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=black)
![GCC](https://img.shields.io/badge/GCC-00599C?style=for-the-badge&logo=gnu&logoColor=white)
![GNU Bash](https://img.shields.io/badge/GNU_Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Overview

This project provides a comprehensive hands-on analysis of Linux system performance tuning using the `strace` diagnostic utility. Conducted on an enterprise Linux environment (CentOS/RHEL), this lab explores low-level kernel interactions, system call diagnostics, live process inspection, and multi-process fork tracing.

By analyzing system calls, we evaluate application I/O overhead, identify performance bottlenecks caused by unbuffered file operations, and inspect non-intrusive monitoring strategies for production systems.

---

## 🛠️ Prerequisites & Lab Environment

* **Platform:** Al Nafi Cloud (CentOS / RHEL 8 Enterprise Environment)
* **Core Utilities:** `strace`, `gcc`, `gdb`, `bash`, standard Linux CLI toolchain
* **User Privileges:** Standard user (`centos`) with `sudo` capabilities

---

## 📁 Screenshot Renaming & Repository Reference

To maintain a clean repository structure, all original terminal output screenshots have been renamed to descriptive filenames and mapped as follows:

| Original Screenshot Name | Portfolio Renamed Filename | Section / Purpose |
| :--- | :--- | :--- |
| `Screenshot (696).png` | `01_basic_strace_execution.png` | Basic C program compilation & standard `strace` execution |
| `Screenshot (697).png` | `02_trace_running_process_pid.png` | Attaching `strace -t -p` to live process (`ping`) via PID |
| `Screenshot (698).png` | `03_syscall_summary_comparison.png` | Performance comparison summary (`strace -c`) |
| `Screenshot (699).png` | `04_trace_child_process_fork_part1.png` | Multi-process fork tracing (`strace -f`) - Part 1 |
| `Screenshot (700).png` | `05_trace_child_process_fork_part2.png` | Library & environment resolution (`strace -f`) - Part 2 |
| `Screenshot (701).png` | `06_trace_child_process_fork_part3.png` | Child process completion & teardown (`strace -f`) - Part 3 |

> **Directory Layout Note:** Store all screenshots under the `docs/images/` folder inside your repository root directory.

---

## 🚀 Lab Execution & Technical Walkthrough

### Task 1: Basic System Call Tracing & Live Process Monitoring

#### 1.1 Environment Verification & Basic Program Execution
We verified system dependencies and authored a target C program (`simple_program.c`) to inspect file opens, buffer reads, memory allocations, and nanosleep execution.

```c
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main() {
    printf("Starting simple program...\n");
    int fd = open("/etc/passwd", O_RDONLY);
    if (fd != -1) {
        char buffer[100];
        read(fd, buffer, sizeof(buffer));
        close(fd);
        printf("File operation completed\n");
    }
    sleep(2);
    printf("Program finished\n");
    return 0;
}
```

We compiled the program and analyzed its execution path with `strace`:
```bash
gcc -o simple_program simple_program.c
strace ./simple_program
```

![Basic System Call Execution](docs/images/01_basic_strace_execution.png)

#### 1.2 Tracing a Running Process via PID (`strace -p`)
We spawned a background `ping` process, retrieved its PID, and attached `strace` non-intrusively to inspect live socket operations (`sendto`, `recvmsg`, `poll`) with relative timestamps (`-t`):

```bash
ping 8.8.8.8 > /dev/null &
PING_PID=$!
echo "New Ping PID: $PING_PID"
strace -t -p $PING_PID
```

![Attach strace to PID](docs/images/02_trace_running_process_pid.png)

---

### Task 2: System Call Profiling & Performance Comparison

#### 2.1 Identifying I/O Bottlenecks (`strace -c`)
System call profiling was performed by comparing an unbuffered/inefficient file operation loop against a buffered implementation using `strace -c`:

```bash
strace -c ./performance_test
```

![Syscall Summary Comparison](docs/images/03_syscall_summary_comparison.png)

**Syscall Overhead Insights:**
* **Inefficient Loop:** Opening and closing files repeatedly inside a loop generates thousands of redundant `openat` and `close` system calls, creating massive context-switching overhead.
* **Efficient Loop:** Writing data sequentially inside single file descriptor sessions drastically reduces total execution time and kernel transitions.

---

### Task 3: Advanced Multi-Process & Subshell Tracing (`strace -f`)

When applications execute child processes via `fork()`, `execve()`, or `clone()`, standard tracing misses child activity. Using `strace -f`, we traced child process lifecycles across subshells.

#### 3.1 Initial Process Execution & Forking
Tracking child creation, process environment initialization, and memory mapping (`mmap`, `brk`):

```bash
strace -f ./test_app
```

![Child Process Fork Part 1](docs/images/04_trace_child_process_fork_part1.png)

#### 3.2 Dynamic Library & SELinux Context Resolution
Monitoring shared object loading (`/lib64/libc.so.6`), locale checks, and SELinux attribute queries (`statfs`, `getxattr`):

![Child Process Fork Part 2](docs/images/05_trace_child_process_fork_part2.png)

#### 3.3 Child Process Termination & Parent Teardown
Tracking standard output write completion (`write`), child exit status propagation (`exit_group(0)`), and parent cleanup via `wait4()`:

![Child Process Fork Part 3](docs/images/06_trace_child_process_fork_part3.png)

---

## 💡 Key Learnings & Optimization Takeaways

1. **Reduce Syscall Frequency:** High-frequency syscalls in application loops drastically increase latency due to user-to-kernel mode switches.
2. **Buffer I/O Operations:** Batching small `read`/`write` requests into larger buffer chunks optimizes file descriptor performance.
3. **Non-Intrusive Production Debugging:** `strace -p <PID>` allows real-time inspection of active services (e.g., `sshd`, `httpd`, `python3`) without disruption.
4. **Follow Process Spawns:** Utilizing the `-f` flag is required when diagnosing complex bash scripts, multi-threaded apps, or child worker processes.

---

## 🏁 Conclusion

This performance tuning lab demonstrated how `strace` provides visibility into the Linux kernel-userland boundary. By analyzing system call traces, calculating call latency distributions, and tracking multi-process executions, we gained practical engineering skills essential for diagnosing application bottlenecks, resolving system resource contention, and optimizing Linux enterprise server performance.