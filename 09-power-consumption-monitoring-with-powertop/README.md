# Lab 09: Power Consumption Monitoring and Tuning with PowerTOP & TLP

p<p align="center">
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="RHEL Logo" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux Logo" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash Logo" />
  <img src="https://img.shields.io/badge/systemd-000000?style=for-the-badge&logo=systemd&logoColor=white" alt="Systemd Logo" />
</p>

---

## 📌 Executive Summary

Modern enterprise system administration demands aggressive power optimization to reduce thermal output, extend hardware operational lifespans, and decrease data center operational expenditure (OpEx). 

This project demonstrates a comprehensive implementation of Linux power monitoring, diagnostic reporting, dynamic kernel parameter tuning, and persistent systemd automation on enterprise RHEL/CentOS systems using **PowerTOP** and **TLP**.

---

## 🧰 Key Features & Implementation Highlights

* **Diagnostic Profiling:** Real-time power usage, CPU wakeups, and process power impact analysis using PowerTOP interactive mode.
* **Automated Data Gathering:** Automated shell scripts to log CPU frequencies, process impact, disk I/O, and battery capacity.
* **Kernel & Power Optimizations:** On-the-fly tuning of kernel parameters including CPU scaling governors, `vm.laptop_mode`, disk I/O schedulers, and USB autosuspend.
* **Persistent Automation:** Integration of system optimization routines into `systemd` background services (`power-optimize.service` and `auto-power-mgmt.service`).
* **Advanced Policy Engine:** Deployment of **TLP** with custom hardware profile switching (`performance`, `balanced`, `powersave`) governed by dynamic battery thresholds.

---

## 📁 Repository Structure

```text
09-power-consumption-monitoring-with-powertop/
├── assets/
│   ├── 01-powertop-overview.png
│   ├── 02-power-analysis-script.png
│   ├── 03-power-optimization-service.png
│   ├── 04-power-dashboard-tlp.png
│   └── 05-auto-power-mgmt-service.png
├── analyze_power.sh
├── auto_power_mgmt.sh
├── cpu_power_mgmt.sh
├── generate_power_report.sh
├── power_dashboard.sh
├── power_optimize.sh
├── power_profiles.sh
└── README.md
```

---

## 🚀 Step-by-Step Implementation & Technical Verification

### Task 1: PowerTOP Installation & Interactive Analysis
PowerTOP was deployed to profile current system power state, wakeups, timer interrupts, and top hardware/process consumers.

```bash
sudo dnf install -y powertop
sudo powertop
```

![PowerTOP Overview Interface](assets/01-powertop-overview.png)
*Figure 1: PowerTOP interactive overview profiling device usage, active interrupts, and system wakeups.*

---

### Task 2: Automated Analysis Scripting
To automate metrics capture, `analyze_power.sh` was written to consolidate CPU scaling frequencies, active network links, disk I/O, and top power-draining processes.

```bash
./analyze_power.sh
```

![Power Analysis Output](assets/02-power-analysis-script.png)
*Figure 2: Execution output of the custom power analysis shell script.*

---

### Task 3: System Optimization & Systemd Service Persistence
A custom optimization script (`power_optimize.sh`) was deployed to dynamically set kernel scaling parameters and enable USB/PCI autosuspend. A systemd service was then registered to ensure parameters persist across system reboots.

```bash
# Verify optimization service status
sudo systemctl status power-optimize.service
```

![Power Optimization Service](assets/03-power-optimization-service.png)
*Figure 3: Systemd status output verifying successful startup and execution of power-optimize.service.*

---

### Task 4 & 5: Live Dashboard, TLP Advanced Configuration & Profiles
To achieve granular power regulation, **TLP** was installed and configured alongside a live terminal dashboard (`power_dashboard.sh`) and multi-profile daemon (`auto_power_mgmt.sh`).

```bash
# Check TLP service status
sudo tlp-stat -s
```

![Power Dashboard and TLP Status](assets/04-power-dashboard-tlp.png)
*Figure 4: Real-time dashboard execution and TLP runtime status summary.*

```bash
# Check automated power management daemon status
sudo systemctl status auto-power-mgmt.service
```

![Auto Power Management Service](assets/05-auto-power-mgmt-service.png)
*Figure 5: Active background auto-power-mgmt service maintaining system power profile rules.*

---

## 🎯 Conclusion

Through the implementation of PowerTOP diagnostics, TLP policy controls, and custom `systemd` service wrappers, this lab successfully establishes a fully automated, dynamic power-tuning infrastructure on Enterprise Linux. 

These configurations effectively reduce idle power waste, optimize kernel governor behaviors under variable load conditions, and deliver persistent enterprise-grade power management.