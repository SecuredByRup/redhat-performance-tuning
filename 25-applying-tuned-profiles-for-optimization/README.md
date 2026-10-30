# Lab 5: Applying Tuned Profiles for Optimization

![Red Hat Enterprise Linux](https://img.shields.io/badge/OS-Red%20Hat%20Enterprise%20Linux%20%2F%20CentOS-red?style=flat-square&logo=redhat)
![AWS EC2](https://img.shields.io/badge/Cloud-AWS%20EC2-orange?style=flat-square&logo=amazonaws)
![Automation](https://img.shields.io/badge/Automation-Bash%20%2F%20Tuned-blue?style=flat-square&logo=gnu-bash)
![DevOps Portfolio](https://img.shields.io/badge/Portfolio-Infrastructure%20Optimization-success?style=flat-square)

## 📌 Overview
This repository documents **Lab 5: Applying Tuned Profiles for Optimization** under the Red Hat Performance Tuning curriculum. The lab explores dynamic system optimization, profile evaluation, custom profile authoring, workload benchmarking, and enterprise compliance auditing using the **`tuned`** framework on cloud-hosted enterprise Linux systems.

---

## 🛠️ Repository Structure

```text
25-applying-tuned-profiles-for-optimization/
├── images/
│   ├── custom-profile-and-stress-test.png
│   ├── profile-comparison-balanced-throughput.png
│   ├── profile-comparison-virtual-custom.png
│   └── profile-switch-and-best-practices.png
├── scripts/
│   ├── performance_monitor.sh          # Baseline & profile metric collection script
│   ├── stress_test.sh                  # Concurrent CPU and I/O workload generator
│   ├── compare_profiles.sh             # Comparative multi-profile log analyzer
│   ├── performance_analysis.sh         # Comprehensive report generator
│   ├── realtime_monitor.sh             # Real-time resource utilization monitor
│   ├── tuned_troubleshoot.sh           # Daemon health & service diagnostics auditor
│   ├── profile_switch_test.sh          # Automated profile switching validator
│   └── tuned_best_practices.sh         # Enterprise compliance & best practices checker
├── custom-lab-profile/
│   └── tuned.conf                      # Custom lab profile configuration template
├── tuned_performance_data/             # Baseline and profile metric logs
├── stress_results_*.log                # Workload execution logs
└── tuned_performance_report.txt        # Aggregated performance analysis report
```

---

## 🚀 Implementation & Execution Details

### 1. Environment Characteristics & Cloud Adaptations
* **Cloud Guest Instance**: Executed on an AWS EC2 RHEL/CentOS guest environment (`172.31.10.43`).
* **Hypervisor Considerations**: Guest-level `cpufreq` paths and legacy SCSI drives (`sda`) are abstracted by the AWS hypervisor. Scripts were built with robust conditional fallbacks to accommodate virtualized NVMe storage (`nvme0n1`) and hypervisor-managed CPU scaling.
* **Recommended Profile**: System recommendation explicitly validated the **`virtual-guest`** profile for optimal cloud performance.

### 2. Built-in Profile Analysis
Evaluated and benchmarked three standard built-in profiles:
* **`balanced`**: General-purpose non-specialized baseline profile.
* **`throughput-performance`**: Broad tuning maximizing server workload throughput.
* **`virtual-guest`**: Memory and kernel tuning tailored for virtual machine guests.

### 3. Custom Profile Authoring (`custom-lab-profile`)
A custom profile was engineered under `/etc/tuned/custom-lab-profile/tuned.conf` inheriting from `balanced` with targeted performance overrides:
* **CPU Governor**: Set to `performance` with `energy_perf_bias=performance`.
* **Memory Management**: Disabled Transparent Huge Pages (`transparent_hugepages=never`) and tuned swappiness (`vm.swappiness=10`).
* **Network Tuning**: Increased maximum socket receive/send buffers (`net.core.rmem_max` and `net.core.wmem_max` set to `134217728`).

---

## 📸 Visual Verification & Screenshots

### Custom Profile Registration & Stress Testing
Below is the verification of `custom-lab-profile` registration via `tuned-adm list`, system recommendation check, custom configuration syntax inspection, and execution of the 30-second concurrent CPU/I/O stress test script:
![Custom Profile and Stress Test](images/custom-profile-and-stress-test.png)

### Multi-Profile Comparative Analysis
Side-by-side performance comparisons evaluating load averages, CPU utilization patterns (`us`, `sy`, `id`, `wa`), and memory consumption across the `balanced` and `throughput-performance` profiles:
![Profile Comparison - Balanced & Throughput](images/profile-comparison-balanced-throughput.png)

Continuation of the comparative analysis evaluating the `virtual-guest` and custom `custom-lab-profile` profiles under identical stress workloads:
![Profile Comparison - Virtual & Custom](images/profile-comparison-virtual-custom.png)

### Automated Profile Switching & Best Practices Audit
Validation of the automated profile switching test script cycling seamlessly through all four profiles, alongside the best-practices compliance checklist audit:
![Profile Switch and Best Practices](images/profile-switch-and-best-practices.png)

---

## 📊 Summary of Custom Automation Scripts

| Script Name | Functionality | Key Commands / Utilities Used |
| :--- | :--- | :--- |
| **`performance_monitor.sh`** | Captures system metrics and kernel tunables. | `uname`, `lscpu`, `sysctl`, `free`, `uptime` |
| **`stress_test.sh`** | Generates 30s CPU and disk I/O load. | `timeout`, `dd`, background jobs (`&`), `top` |
| **`compare_profiles.sh`** | Parses and compares multi-profile logs. | `grep`, `awk`, conditional checks |
| **`realtime_monitor.sh`** | Interactive live resource utilization monitor. | `sleep` loop, `clear`, `sysctl`, `free` |
| **`tuned_troubleshoot.sh`** | Audits `tuned` daemon health and journal logs. | `systemctl`, `journalctl`, `ps` |
| **`profile_switch_test.sh`**| Validates sequential profile switching and verification. | `tuned-adm profile`, `tuned-adm verify` |
| **`tuned_best_practices.sh`**| Audits enterprise compliance and service status. | `systemctl is-enabled`, configuration checks |

---

## 🏆 Conclusion
Lab 5 successfully demonstrated the mastery of dynamic system tuning using Red Hat's **`tuned`** framework. By transitioning from built-in profiles (`balanced`, `throughput-performance`, `virtual-guest`) to authoring and deploying a tailored **`custom-lab-profile`**, system performance was optimized for specific workload requirements. Furthermore, writing robust Bash automation scripts for benchmarking, stress testing, and auditing established a rigorous, repeatable DevOps methodology for enterprise Linux infrastructure management.