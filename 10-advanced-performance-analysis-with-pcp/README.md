# Lab 10: Advanced Performance Analysis with Performance Co-Pilot (PCP)

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Performance Co-Pilot](https://img.shields.io/badge/PCP-Performance_Co--Pilot-00599C?style=for-the-badge&logo=linux&logoColor=white)
![Bash](https://img.shields.io/badge/Bash_Automation-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux Shell](https://img.shields.io/badge/Linux_Kernel-FCC624?style=for-the-badge&logo=linux&logoColor=black)

---

## Executive Summary

**Lab 10: Advanced Performance Analysis with PCP** demonstrates distributed system metric collection, historical logging, inference rule evaluation, and automated cluster health monitoring across a simulated multi-node Red Hat Enterprise Linux environment. 

Using **Performance Co-Pilot (PCP)**, this project establishes continuous observability over CPU, memory, disk, and kernel subsystems across multiple endpoints (`localhost`, `target-1`, `target-2`). It includes custom shell tools for multi-node query aggregation, automated threshold inferencing, trend parsing from PCP archive files (`pmlogger`), formatted HTML reporting, and continuous background health logging.

---

## Key Technical Objectives

* **Multi-Node Host Resolution**: Configure local loopback mappings in `/etc/hosts` to simulate multi-system PCP architecture.
* **PMDA Subsystem Verification**: Validate active Performance Metrics Domain Agents (PMDAs) for `kernel`, `proc`, `disk`, and `mem`.
* **Real-Time Data Aggregation**: Deploy shell tools (`multi_system_monitor.sh`, `pmstat_all.sh`) for real-time cluster sampling.
* **Historical Logging & Archive Parsing**: Configure `pmlogger` daemons, generate synthetic stress profiles using `stress-ng`, and parse metric trends from archive binaries using `pmdumptext`.
* **Inference Rule Engine**: Write custom rule definitions in `pmie_rules.local` to evaluate real-time system state and flag rule breaches.
* **Reporting & Automated Health Monitoring**: Develop automated text dashboards, side-by-side comparative query tools, styled HTML report generators, and continuous daemon background monitors (`automated_monitoring.sh`).

---

## Directory & Script Structure

```text
10-advanced-performance-analysis-with-pcp/
├── automated_monitoring.sh                     # Background daemon script for cluster health logging
├── comparative_analysis.sh                   # Cross-host side-by-side metric comparison script
├── comprehensive_report.sh                   # Formatted HTML report generator tool
├── generate_load.sh                          # Synthetic stress generator (stress-ng & memory hogs)
├── multi_system_monitor.sh                   # Multi-endpoint metric gathering script
├── performance_dashboard.sh                  # Text-based host report builder
├── pcp_comprehensive_report_*.html          # HTML output report containing cluster metrics
├── pcp_reports/                              # Output folder storing host-level text summaries
│   ├── localhost_summary_*.txt
│   ├── target-1_summary_*.txt
│   └── target-2_summary_*.txt
├── pmie_rules.local                          # Custom rule definitions for Performance Metrics Inference Engine
├── pmstat_all.sh                             # System performance overview wrapper
├── trend_analysis.sh                         # Archive trend parsing script using pmdumptext
├── pcp-load-testing-and-inference-verification.png  # Execution evidence (Screenshot 638)
└── comparative-analysis-and-automated-monitoring.png # Verification evidence (Screenshot 639)
```

---

## Architecture & Multi-Node Setup

The environment simulates a multi-node enterprise monitoring cluster on a single EC2 RHEL host using loopback network aliases.

```
                  +-----------------------------------+
                  |   PCP Monitoring Hub (pmcd)       |
                  |     ip-172-31-10-61.ec2.internal    |
                  +-----------------+-----------------+
                                    |
             +----------------------+----------------------+
             |                      |                      |
             v                      v                      v
     +---------------+      +---------------+      +---------------+
     |   localhost   |      |   target-1    |      |   target-2    |
     | (127.0.0.1)   |      | (127.0.0.1)   |      | (127.0.0.1)   |
     +---------------+      +---------------+      +---------------+
     | PMDAs:        |      | PMDAs:        |      | PMDAs:        |
     | kernel, proc, |      | kernel, proc, |      | kernel, proc, |
     | disk, mem     |      | disk, mem     |      | disk, mem     |
     +---------------+      +---------------+      +---------------+
```

### Network Resolution Setup
To enable multi-endpoint metric querying via standard hostname flags (`-h <host>`), the local `/etc/hosts` file was updated:

```text
127.0.0.1   localhost localhost.localdomain target-1 target-2
```

---

## Implementation & Custom Tooling

### 1. Synthetic Load Generation (`generate_load.sh`)
Executes bounded 30-second CPU and memory stress profiles using `stress-ng` to induce measurable load spikes across PCP agents:

```bash
#!/bin/bash
echo "Generating system load for testing..."
stress-ng --cpu 2 --vm 1 --vm-bytes 256M --timeout 30s
echo "Load generation complete!"
```

### 2. Inference Engine Configuration (`pmie_rules.local`)
Defines automated threshold detection logic evaluated in real-time by `pmie`:

```text
// High CPU utilization rule (> 80%)
(kernel.all.cpu.user + kernel.all.cpu.sys) > 80 
    -> print "High CPU utilization: %v%%";

// High memory usage rule (> 90%)
(100 * mem.util.used / mem.physmem) > 90 
    -> print "High memory usage: %v%%";

// High load average rule (> 4.0)
kernel.all.load #'1 minute' > 4 
    -> print "High load average: %v";
```

### 3. Comparative Metric Querying (`comparative_analysis.sh`)
Queries core kernel metrics simultaneously across all target hosts to evaluate cluster-wide consistency:

```bash
#!/bin/bash
HOSTS=("localhost" "target-1" "target-2")
METRICS=("kernel.all.cpu.user" "mem.util.used" "kernel.all.load")

echo "Comparative Performance Analysis"
echo "==============================="

for metric in "${METRICS[@]}"; do
    echo ""
    echo "Metric: $metric"
    echo "--------------------------------------------------"
    for host in "${HOSTS[@]}"; do
        value=$(pminfo -h "$host" -f "$metric" 2>/dev/null | grep value | awk '{print $2}' | head -1)
        printf "%-12s: %s\n" "$host" "${value:-N/A}"
    done
done
```

### 4. Automated Cluster Health Daemon (`automated_monitoring.sh`)
Runs background health sweeps across all target aliases and appends structured health records to `/var/log/pcp_monitoring.log`:

```bash
#!/bin/bash
HOSTS=("localhost" "target-1" "target-2")
LOG_FILE="/var/log/pcp_monitoring.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Starting automated PCP cluster health check..." | sudo tee -a "$LOG_FILE" >/dev/null

for host in "${HOSTS[@]}"; do
    if pminfo -h "$host" kernel.all.load >/dev/null 2>&1; then
        STATUS="ONLINE"
        LOAD=$(pminfo -h "$host" -f kernel.all.load 2>/dev/null | grep value | head -1 | awk -F '=' '{print $2}')
        [ -z "$LOAD" ] && LOAD=$(pminfo -h "$host" kernel.all.load | awk '{print $NF}')
    else
        STATUS="OFFLINE"
        LOAD="N/A"
    fi
    echo "[$TIMESTAMP] Host: $host | Status: $STATUS | 1-min Load: $LOAD" | sudo tee -a "$LOG_FILE"
done
```

---

## Execution Verification & Screenshot Evidence

### 1. Host Mapping, Load Generation, and Inference Rule Evaluation
The screenshot below documents host alias mapping in `/etc/hosts`, host verification via `pminfo -h target-1 kernel.all.load`, synthetic stress test execution with `stress-ng`, and active rule evaluation by `pmie` using `./pmie_rules.local`.

![PCP Load Testing and Inference Verification](pcp-load-testing-and-inference-verification.png)

* **Image Reference File**: `pcp-load-testing-and-inference-verification.png` *(Renamed from Screenshot (638).png)*

---

### 2. Comparative Analysis and Automated Health Logging
The screenshot below shows the successful execution of `comparative_analysis.sh` pulling CPU, memory, and load metrics across endpoints, followed by `automated_monitoring.sh` execution and verification of persistent log entries in `/var/log/pcp_monitoring.log`.

![Comparative Analysis and Automated Monitoring](comparative-analysis-and-automated-monitoring.png)

* **Image Reference File**: `comparative-analysis-and-automated-monitoring.png` *(Renamed from Screenshot (639).png)*

---

## Conclusion

Lab 10 successfully validates the deployment, configuration, and automation of **Performance Co-Pilot (PCP)** in an enterprise Red Hat Enterprise Linux environment. By combining core PCP utilities (`pmcd`, `pminfo`, `pmlogger`, `pmie`, `pmdumptext`) with custom Bash automation wrappers, this project delivers:

1. **Multi-Node Observability**: Standardized metric acquisition across multiple simulated cluster targets.
2. **Automated Anomaly Detection**: Real-time evaluation of rule-based performance thresholds without manual intervention.
3. **Historical Analysis & Reporting**: Seamless extraction of metric trends from binary log archives into structured HTML and text reports.
4. **Operational Readiness**: Lightweight background health monitoring for continuous cluster tracking and incident response logging.