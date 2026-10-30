# Lab 17: Database Performance Tuning & Optimization

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat%20Enterprise%20Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash Shell](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

---

## 📋 Executive Summary
This laboratory report details the systematic performance tuning, kernel optimization, connection pooling, and workload benchmarking for PostgreSQL database engines deployed on Enterprise Linux (**RHEL/CentOS 9**). 

The primary goal of this optimization suite is to maximize transactional throughput, eliminate disk I/O bottlenecks on NVMe storage, configure network backlogs for high-concurrency client connections, and establish persistent system configurations.

---

## 🏗️ Architecture & Operational Environment

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      RHEL / CentOS 9 Cloud Instance                    │
│                                                                        │
│   ┌─────────────────────┐                 ┌────────────────────────┐   │
│   │   Kernel / Sysctl   │                 │   NVMe Storage Volume  │   │
│   │  vm.swappiness=10   │                 │      (/dev/nvme0n1)    │   │
│   │  vm.dirty_ratio=15  │                 │    XFS Filesystem      │   │
│   └──────────┬──────────┘                 └───────────┬────────────┘   │
│              │                                        │                │
│              ▼                                        ▼                │
│   ┌─────────────────────┐                 ┌────────────────────────┐   │
│   │  PgBouncer Pooler   │                 │  Deadline I/O Scheduler│   │
│   │     (Port 6432)     │                 │   read_expire = 150ms  │   │
│   └──────────┬──────────┘                 └───────────┬────────────┘   │
│              │                                        │                │
│              ▼                                        ▼                │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │                     PostgreSQL Database                        │   │
│   │                   shared_buffers = 128MB                       │   │
│   │                  pg_stat_statements enabled                    │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

* **Operating System:** Red Hat Enterprise Linux / CentOS 9 (x86_64)
* **Storage Architecture:** NVMe SSD (`/dev/nvme0n1p4`) formatted with **XFS Filesystem**
* **Database Management Engine:** PostgreSQL 15+
* **Connection Management:** PgBouncer (Transaction Pooling mode on Port `6432`)
* **Persistence Layer:** Boot-time parameter execution via `/etc/rc.local` and systemd integration

---

## 🛠️ Implementation Breakdown

### Task 1: Disk, Memory & Kernel Parameter Tuning
To minimize system swapping and prevent unannounced high-latency disk write surges during peak database traffic, key Linux kernel virtual memory (`vm`) parameters were reconfigured:
* **Virtual Memory Swappiness:** Set `vm.swappiness = 10` (or `1`) to enforce RAM prioritization over page cache swapping.
* **Dirty Page Ratios:** Set `vm.dirty_ratio = 15` and `vm.dirty_background_ratio = 5` to flush cached dirty pages to disk in smaller, continuous bursts.
* **Storage Readahead:** Adjusted storage volume readahead buffers (`/sys/block/nvme0n1/queue/read_ahead_kb`) to align with database block sizes.

---

### Task 2: I/O Scheduling & Network Stack Buffers

#### 1. Deadline I/O Scheduler Fine-Tuning
The default multiqueue block scheduler was tuned specifically for high-frequency database read/write transaction profiles:
* **Scheduler Assignment:** Configured `deadline` / `mq-deadline` scheduler on `/dev/nvme0n1`.
* **Read/Write Expirations:** `read_expire = 150ms` and `write_expire = 1500ms` to prevent read starvation during heavy batch write operations.
* **Queue Depth & Merges:** Set `front_merges = 1`, `writes_starved = 6`, and `nr_requests = 32`.
* **Persistence:** Automated via custom shell script `/usr/local/bin/database-io-tuning.sh` triggered on boot through `/etc/rc.local`.

#### 2. Network Buffer Expansion (`/etc/sysctl.conf`)
* **TCP Socket Memory:** Enforced maximum TCP socket read/write buffer boundaries (`net.core.rmem_max = 16777216`, `net.core.wmem_max = 16777216`).
* **Connection Backlogs:** Increased SYN backlog (`net.ipv4.tcp_max_syn_backlog = 8192`) and device input queues (`net.core.netdev_max_backlog = 5000`).

#### 3. Service Status & Kernel Verification
Below is the system snapshot confirming the active XFS filesystem on `/dev/nvme0n1p4`, tuned kernel parameters, and active statuses for PostgreSQL and PgBouncer.

![System Status and Kernel Parameters](system_status_and_kernel_tuning.png)

---

### Task 3: Connection Pooling, Data Population & Workload Analysis

#### 1. PgBouncer Connection Pooler
* Configured transaction-level connection pooling listening on port `6432`.
* Allocated `default_pool_size = 25`, `reserve_pool_size = 5`, and `max_client_conn = 100`.

#### 2. Database Schema & Data Generation (`populate_data.sql`)
Populated `testdb` with indexed relations to simulate realistic enterprise data volumes:
* **`customers` table:** 100,000 generated records with indexed emails.
* **`orders` table:** 500,000 generated transactional records linked via foreign key to customer IDs with datetime indexes.
* **Query Planner Statistics:** Ran `ANALYZE` across all tables to refresh table statistics for the query optimizer.

#### 3. Concurrent Workload Benchmark Execution (`db_workload_test.sh`)
Executed a multi-threaded workload benchmark generating 20 concurrent connections executing analytical complex join and aggregate queries over a 60-second test window.

![Database Workload Execution](db_workload_test_execution.png)

#### 4. Performance Analysis Reporting (`analyze_performance.sh`)
Utilized `pg_stat_statements` to track average execution times, call counts, table scan statistics, and overall system memory distribution.

![Database Performance Analysis](database_performance_analysis.png)

---

## 📁 Repository Structure

```text
36-performance-tuning-for-databases/
├── README.md
└── scripts/
    ├── analyze_performance.sh       # Automated system resource & pg_stat analysis report
    ├── database-io-tuning.sh        # Boot-persistent deadline I/O scheduler tuning
    ├── db_workload_test.sh          # Multi-threaded concurrent query benchmark simulation
    ├── performance_comparison.sh    # Verification script for sysctl & PostgreSQL settings
    └── populate_data.sql            # Schema creator & 600k sample dataset generator
```

---

## 📸 Screenshot Mapping Reference Table

| Screenshot File Name | Function / Command Output Demonstrated | Key Verification Findings |
| :--- | :--- | :--- |
| `system_status_and_kernel_tuning.png` | `df -Th`, `cat /sys/block/nvme0n1/queue/*`, `sysctl`, `systemctl status` | Validates XFS volume (`/dev/nvme0n1p4`), deadline `read_expire` (150ms), socket `rmem_max` (16MB), and active PostgreSQL/PgBouncer processes. |
| `db_workload_test_execution.png` | `/home/centos/.../scripts/db_workload_test.sh` | Confirms execution of the multi-connection benchmark driver testing connection concurrency under stress. |
| `database_performance_analysis.png` | `./analyze_performance.sh` | Displays memory availability (14Gi free), uptime load averages, query call counts, and detailed query runtime breakdowns via `pg_stat_statements`. |

---

## 🎯 Conclusion
Through targeted kernel parameter tuning, deadline I/O queue optimization for NVMe block devices, TCP socket window adjustments, and PgBouncer connection pooling, the database instance achieved optimized transactional latency and predictable page-cache management. The integrated `pg_stat_statements` analysis toolkit provides continuous observability over top query runtimes and database cache efficiency.

---
*Maintained by [SecuredByRup](https://github.com/SecuredByRup)*