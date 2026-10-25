# Lab 12: Hardware Profiling with `dmidecode`

![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)

## Executive Summary
This lab demonstrates system hardware auditing, profiling, and performance assessment on enterprise Linux servers using `dmidecode`. By querying Desktop Management Interface (DMI) and System Management BIOS (SMBIOS) tables, detailed hardware metrics were extracted without requiring physical server access or system downtime. Automated Bash profiling scripts were developed to inspect CPU topology, memory channel alignment, baseboard characteristics, and system firmware configurations, establishing repeatable hardware baselines for enterprise auditing.

---

## Technical Objectives
- **SMBIOS Table Querying:** Extract system management data using standardized DMI table structures (Type 0 through 17).
- **CPU & Architecture Profiling:** Inspect processor models, core/thread counts, cache hierarchies, and operational clock speeds.
- **Memory Subsystem Inspection:** Audit RAM capacity, slot population, module speeds, and channel architecture.
- **System & Firmware Verification:** Analyze motherboard characteristics, UEFI/Legacy BIOS settings, and firmware release dates.
- **Automated Performance Auditing:** Create custom Bash utilities to automate hardware profiling and establish version-controlled hardware performance baselines.

---

## Lab Architecture & Workflow

```
               +-------------------------------------------+
               |              dmidecode / DMI             |
               |             SMBIOS Interface             |
               +---------------------+---------------------+
                                     |
         +---------------------------+---------------------------+
         |                           |                           |
         v                           v                           v
+------------------+       +------------------+       +------------------+
| Type 4: CPU      |       | Type 16/17: RAM  |       | Type 0/1: System |
| Core/Thread Info |       | Slot & Channel   |       | BIOS & Firmware  |
+--------+---------+       +--------+---------+       +--------+---------+
         |                           |                           |
         +---------------------------+---------------------------+
                                     |
                                     v
                       +---------------------------+
                       |    Automated Profiling    |
                       |    & Baseline Analysis    |
                       +---------------------------+
```

---

## Step-by-Step Implementation & Execution

### 1. DMI Entry Auditing and CPU Analysis
The initial step involved identifying system DMI handles and querying CPU attributes. Running `cpu_analyzer.sh` evaluated clock speeds, core topology, and socket capabilities.

```bash
# Verify DMI handles and execute CPU profiling
sudo dmidecode | grep "Handle" | wc -l
chmod +x cpu_analyzer.sh
./cpu_analyzer.sh
```

![CPU Analysis and DMI Handle Count](./cpu-analysis-and-handle-count.png)
*Figure 1: Execution of `cpu_analyzer.sh` displaying CPU clock speeds, core topology, cache layout, and SMBIOS entry handle counts.*

### 2. Memory Subsystem & Channel Optimization
Memory module slots and channel architectures were audited using `memory_analyzer.sh` and `memory_channel_analyzer.sh`. The analysis identified total installed RAM and flagged single-channel limitations due to unpopulated memory slots.

```bash
# Audit memory configuration and channel population
./memory_analyzer.sh
./memory_channel_analyzer.sh
```

![Memory Subsystem and Channel Analysis](./memory-and-channel-analysis.png)
*Figure 2: Memory module evaluation highlighting single 16 GiB DDR4 DIMM detection and dual-channel capability warnings.*

### 3. Master Performance Assessment and Baseline Generation
To consolidate diagnostic output, `performance_analyzer.sh` aggregated CPU, memory, and firmware metrics into a single report. Additionally, `create_baseline.sh` captured a complete hardware snapshot into a timestamped directory for future drift detection.

```bash
# Generate comprehensive hardware analysis and baseline snapshot
./performance_analyzer.sh
./create_baseline.sh
```

![Comprehensive Performance Analysis and Baseline Creation](./comprehensive-performance-baseline.png)
*Figure 3: Combined execution of master performance analyzer and creation of version-controlled baseline files.*

---

## Portfolio Scripts Overview

| Script Name | DMI Type Query | Primary Function |
| :--- | :--- | :--- |
| `cpu_analyzer.sh` | Type 4 | Analyzes CPU architecture, core/thread ratios, and clock speed throttling. |
| `memory_analyzer.sh` | Type 16, 17 | Inspects RAM capacities, slot populating, and DIMM frequencies. |
| `memory_channel_analyzer.sh` | Type 17 | Evaluates memory slot layout for dual/quad channel optimization. |
| `system_analyzer.sh` | Type 0, 1, 2, 3 | Audits BIOS release dates, system UUIDs, motherboard models, and UEFI status. |
| `expansion_analyzer.sh` | Type 8, 9, 10, 41 | Profiles expansion slots, onboard devices, and system port configurations. |
| `performance_analyzer.sh` | Integrated | Generates enterprise hardware performance recommendations across components. |
| `hardware_inventory.sh` | Master Audit | Formats complete SMBIOS data into timestamped hardware inventory text files. |
| `create_baseline.sh` | Snapshot Utility | Captures configuration state and provides an automated diff/comparison script. |

---

## Conclusion
Through this lab, hardware profiling was successfully implemented using standard Linux SMBIOS querying techniques. The automated script suite provides sysadmins with quick insights into server configurations, memory channel utilization, and processor scaling parameters without physical hardware inspection. The baseline snapshot utilities ensure clear hardware tracking and change management across enterprise deployments.