# Lab 15: Modifying Kernel Parameters with `sysctl`

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Executive Summary
Kernel parameter optimization is a foundational aspect of Linux systems administration and performance engineering. The Linux kernel exposes runtime configurable parameters through the `/proc/sys/` virtual filesystem, which can be modified using the `sysctl` utility.

This lab demonstrates end-to-end management of Linux kernel parameters, transitioning from runtime memory and network adjustments to persistent drop-in configurations (`/etc/sysctl.d/`). Furthermore, it highlights operational best practices through custom automation scripts for baseline audits, automated configuration validation, backup/restore workflows, and dynamic role-based tuning profiles tailored for high-throughput enterprise workloads (e.g., Web Servers and Database Servers).

---

## 🎯 Key Objectives
1. **Kernel Subsystem Exploration:** Interrogate baseline system parameters across memory, networking, and security subsystems using `sysctl`.
2. **Dynamic Runtime Tuning:** Modify live virtual memory management (e.g., `swappiness`, `dirty_ratio`, `vfs_cache_pressure`) and TCP socket parameters without system reboots.
3. **Persistence Engineering:** Enforce permanent changes across system reboots using custom priority configurations in `/etc/sysctl.d/`.
4. **Validation & Operations Automation:** Implement custom Bash utilities to validate live parameters against expected baseline configurations and manage operational backups.
5. **Role-Based Workload Optimization:** Build a profile management script to switch system configurations dynamically between Database and Web Server workload requirements.

---

## 🏗️ Technical Architecture & Key Parameters

| Subsystem | Parameter | Baseline / Target | Operational Purpose |
| :--- | :--- | :--- | :--- |
| **Memory (VM)** | `vm.swappiness` | `10` | Reduces aggressiveness of swap utilization, keeping active pages in RAM. |
| **Memory (VM)** | `vm.dirty_ratio` | `15` | Percentage of system memory filled with dirty pages before processes block to write. |
| **Memory (VM)** | `vm.vfs_cache_pressure` | `50` / `200` | Controls tendency of the kernel to reclaim memory used for directory and inode caching. |
| **Network** | `net.core.somaxconn` | `65535` | Maximum socket listen queue size for high-concurrency connection handling. |
| **Network** | `net.ipv4.tcp_rmem` / `wmem` | Scaled | Dynamic TCP receive/send buffer allocation (min, default, max bytes). |
| **IPC / System** | `kernel.shmmax` | `68719476736` | Maximum size of a single shared memory segment (critical for DBMS shared buffers). |
| **File System** | `fs.file-max` | `2097152` | System-wide limit for open file handles across all processes. |

---

## 🚀 Execution & Implementation Steps

### Task 1: Baseline Auditing & Runtime Parameter Tuning
Before modifying system parameters, an initial audit script (`explore_sysctl.sh`) was executed to capture system state. Runtime modifications were then applied using `sudo sysctl` to optimize memory page management and socket buffer allocation on the fly.

```bash
# Apply dynamic memory and socket buffer changes
sudo sysctl vm.swappiness=10
sudo sysctl vm.dirty_ratio=15
sudo sysctl vm.vfs_cache_pressure=50
```

![Baseline and Runtime Tuning](screenshots/01_baseline_and_runtime_tuning.png)
*Figure 1: Auditing system baselines and modifying live virtual memory and network settings.*

---

### Task 2: Persistent Configuration & Automated Validation
To maintain parameter state across system reboots, settings were declared in a priority configuration file `/etc/sysctl.d/99-performance-tuning.conf`. The automated validation script (`validate_config.sh`) was executed to verify that live system state matched the persistent configuration targets cleanly.

```bash
# Load persistent parameters and validate active state
sudo sysctl --system
./validate_config.sh
```

![Persistent Configuration Validation](screenshots/02_persistent_config_validation.png)
*Figure 2: Loading `/etc/sysctl.d/` drop-in files and executing automated parameter validation.*

---

### Task 3: Dynamic Role-Based Profile Engine
To streamline workload-specific tuning, a profile manager script (`sysctl_profiles.sh`) was created. The script writes targeted configurations (e.g., Database or Web Server profiles) to `/etc/sysctl.d/90-*.conf` and reloads the system configuration state dynamically.

```bash
# Apply the high-performance Database tuning profile
./sysctl_profiles.sh database
```

![Database Profile Application](screenshots/03_database_profile_application.png)
*Figure 3: Generating and applying the custom Database Performance Profile.*

---

### Task 4: Active Profile State Verification
Following the application of the Database profile, active system settings were queried to confirm that parameters like `kernel.shmmax`, `fs.file-max`, and `vm.vfs_cache_pressure` were successfully reconfigured.

```bash
# Verify active parameters post-profile switch
sysctl vm.swappiness vm.vfs_cache_pressure kernel.shmmax fs.file-max
```

![Database Profile Verification](screenshots/04_database_profile_verification.png)
*Figure 4: Confirming active database kernel parameters (`shmmax`, `file-max`, and cache pressure).*

---

## 🛠️ Automation Utility Reference

The lab repository includes several helper scripts designed to simplify sysctl management:

1. **`explore_sysctl.sh`**: Interrogates the current system state for memory, networking, and kernel security values.
2. **`backup_sysctl.sh`**: Captures a snapshot of current runtime parameter values into a timestamped file before changes are made.
3. **`restore_sysctl.sh`**: Restores system parameters from a designated backup configuration file.
4. **`validate_config.sh`**: Reads `/etc/sysctl.d/99-performance-tuning.conf` and compares defined targets against active live kernel values (`sysctl -n`).
5. **`sysctl_profiles.sh`**: Automates profile switching between `webserver`, `database`, and `default` operational configurations.

---

## 📝 Conclusion
This lab demonstrates the power and flexibility of Linux kernel parameter management through `sysctl`. By combining dynamic runtime testing with persistent configuration files in `/etc/sysctl.d/`, administrators can fine-tune system performance safely and predictably. Furthermore, integrating operational scripts for validation, backups, and role-based profiling ensures that kernel performance tuning is both reproducible and maintainable across enterprise deployment workflows.