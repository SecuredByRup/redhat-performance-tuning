# Lab 16: Kernel Module Parameter Tuning & Performance Optimization

![Red Hat Enterprise Linux](https://img.shields.io/badge/OS-Red%20Hat%20Enterprise%20Linux-Red?style=for-the-badge&logo=redhat&logoColor=white)
![Linux Kernel](https://img.shields.io/badge/Kernel-Parameter%20Tuning-blue?style=for-the-badge&logo=linux&logoColor=white)
![AWS EC2](https://img.shields.io/badge/Cloud-AWS%20EC2-orange?style=for-the-badge&logo=amazonaws&logoColor=white)
![Systemd](https://img.shields.io/badge/Automation-Systemd%20&%20Bash-green?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📋 Overview
This lab covers advanced **Linux kernel parameter tuning** and system resource optimization under Red Hat Enterprise Linux / CentOS. The objective is to optimize kernel subsystems—specifically network buffer handling, virtual memory management, and multi-queue NVMe storage I/O schedulers—to maximize throughput, reduce latency, and ensure configurations persist reliably across system reboots using enterprise automation tools (`systemd` and `sysctl`).

---

## ☁️ Cloud Environment Adaptations
Because this lab runs inside an **AWS EC2 cloud instance**, standard bare-metal configurations required the following hypervisor-specific adaptations:
* **Network Interface:** Tuned cloud virtual network interface **`ens5`** (utilizing ENA/virtio drivers) instead of `eth0`, capping ring buffers at the hypervisor maximum limit of **`1024`** (`rx` and `tx`).
* **Storage Subsystem:** Targeted high-performance **NVMe block devices (`nvme0n1`)** instead of traditional legacy SCSI/SATA `sda` drives, deploying the modern multi-queue **`mq-deadline`** I/O scheduler.

---

## 🛠️ Implementation Steps

### **Task 1: Network & Ring Buffer Tuning (`ens5`)**
* Inspected and configured ENA driver ring buffer sizes to instance maximums (`1024`).
* Enabled TCP Segmentation Offload (`tso on`) and Generic Receive Offload (`gro on`) to minimize CPU interrupt overhead.

### **Task 2: NVMe Storage & Virtual Memory Tuning (`nvme0n1`)**
* Switched the primary storage I/O scheduler to **`mq-deadline`** optimized for multi-queue NVMe devices.
* Increased read-ahead cache (`512 KB`) and request queue depth (`128`) for heavy sequential and random workloads.
* Optimized virtual memory thresholds via `sysctl`:
  * `vm.dirty_ratio = 10` & `vm.dirty_background_ratio = 5` (smoothes out write spikes and triggers early background flush).
  * `vm.swappiness = 10` (favors retaining active physical RAM over aggressive swapping).

### **Task 3: Performance Evaluation & Benchmarking (`fio`)**
* Executed rigorous multi-job storage benchmarking (`fio`) covering random 4K reads/writes and sequential 64K workloads.
* Monitored active system performance and disk throughput using `iostat`, `mpstat`, and custom monitoring scripts.

### **Task 4: Persistence Automation & Validation**
* Created persistent kernel parameters in `/etc/sysctl.d/99-performance-tuning.conf`.
* Engineered custom `systemd` oneshot services (`storage-tuning.service` and `network-tuning.service`) to enforce storage queue depths and network offloads automatically on boot.
* Developed and validated execution via an automated verification script (`validate_tuning.sh`).

---

## 📸 Execution & Verification Screenshots

### **1. Ring Buffer & NVMe Storage Tuning**
![Ring Buffer and NVMe Tuning](images/01-ringbuffer-and-nvme-tuning.png)  
*Figure 1: Verification of `ens5` ring buffer limits (`1024`), NVMe scheduler parameters, VM sysctl settings, and initial `fio` benchmark launch[cite: 1].*

### **2. Storage Benchmarking Results (`fio`)**
![Storage Benchmarks](images/02-fio-storage-benchmarks.png)  
*Figure 2: Execution of random and sequential storage performance tests via `fio`, displaying IOPS, throughput metrics, and underlying NVMe disk statistics[cite: 2].*

### **3. Persistence Validation & Service Status**
![Persistence and Validation](images/03-persistence-services-and-validation.png)  
*Figure 3: Systemd active state verification for `storage-tuning.service` and `network-tuning.service`, alongside successful execution of `validate_tuning.sh` confirming all 6 checks passed with zero errors[cite: 4].*

---

## 📌 Conclusion
Lab 16 successfully demonstrates advanced Linux kernel parameter tuning and system optimization in a cloud-native architecture. By adapting legacy storage and network paths to modern NVMe (`nvme0n1`) and ENA (`ens5`) standards, and by codifying these settings into automated `systemd` services and `sysctl` rules, the instance achieves superior I/O throughput, minimized network latency, and robust enterprise-grade persistence across reboots.
