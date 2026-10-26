# Lab 3: Using top to Analyze System Behavior

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-Enterprise%20Linux-CC0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS Stream](https://img.shields.io/badge/CentOS-Stream-26252D?style=for-the-badge&logo=centos&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Server-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

## Overview
This directory contains hands-on lab exercises and automation scripts for **Lab 3: Using top to Analyze System Behavior** under the Red Hat performance tuning curriculum. The focus is on mastering real-time process monitoring, system load analysis, resource bottleneck identification, and process scheduling priority adjustments using `top`, `nice`, and `renice`.

---

## Directory Structure
```text
03-using-top-to-analyze-system-behavior/
├── resource_test.sh
├── system_monitor.sh
├── priority_manager.sh
├── performance_test.sh
├── top_monitor.sh
├── monitoring_best_practices.sh
└── screenshots/
    ├── top-interface.png
    ├── resource-monitoring.png
    └── priority-manager.png
```

---

## Things Covered in This Lab

### Task 1: Real-Time Monitoring with `top`
* **Interface & Headers**: Analyzed system uptime, user count, load averages (1, 5, and 15-minute intervals), total/running/sleeping tasks, CPU distribution (`%us`, `%sy`, `%ni`, `%id`, `%wa`), and physical/swap memory metrics.
* **Interactive Navigation**: Practiced essential hotkeys (`P` to sort by CPU usage, `M` to sort by memory consumption, `1` for per-core CPU view, `f` for field management, and `u` for user filtering).

### Task 2: Identifying Resource Hogs and Inefficiencies
* **Workload Simulation (`resource_test.sh`)**: Created CPU-intensive calculation loops using `bc`, memory allocation scripts via Python, and I/O stress tests using `dd` and file operations.
* **Automated Diagnostics (`system_monitor.sh`)**: Built script utilities to automatically check CPU core distribution, load averages, memory status, disk space (`df -h`), network sockets, and top resource-consuming processes.

### Task 3: Modifying Process Priorities (`nice` and `renice`)
* **Scheduling Priorities**: Explored nice values ranging from `-20` (highest priority, root privileges required) to `+19` (lowest priority).
* **Priority Management (`priority_manager.sh`)**: Developed wrapper scripts to list process priorities, modify running task weights dynamically via `renice`, and monitor scheduling performance impacts.

---

## Lab Screenshots

* **Interactive `top` Session**: Displaying real-time process distribution, per-core CPU usage, and memory headers.
  
  ![Top Interface](screenshots/top-interface.png)

* **Resource Monitoring Execution**: Executing system diagnostic scripts and observing resource consumer distributions.
  
  ![Resource Monitoring](screenshots/resource-monitoring.png)

* **Process Priority Management**: Inspecting active process IDs, parent PIDs, and nice values (`NI`) via priority utility scripts.
  
  ![Priority Manager](screenshots/priority-manager.png)

---

## Conclusion
This lab successfully demonstrated advanced system observability and process control using `top` and scheduling utilities. By mastering real-time metric interpretation, automated diagnostic scripting, and priority tuning (`nice`/`renice`), system administrators can proactively mitigate performance bottlenecks and maintain optimal resource distribution across enterprise Linux deployments.