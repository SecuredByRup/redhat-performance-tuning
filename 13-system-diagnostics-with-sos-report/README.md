# Lab 13: System Diagnostics & Performance Analysis with `sos report`

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

---

## 📌 Executive Overview
This laboratory module demonstrates enterprise-grade system diagnostics, log aggregation, and automated health evaluation using **Red Hat's `sos report` utility (v4.11.2)**. 

The primary focus is performing targeted subsystem diagnostics, handling modern non-interactive archive extractions, managing permissions across non-root accounts, parsing structural data directories (`proc/`, `etc/`, `sos_commands/`), and building custom performance analysis tools for ongoing site reliability engineering (SRE) workflows.

---

## 🎯 Key Objectives
* **Targeted Diagnostic Collection:** Utilize `sos report` with explicit plugin controls (`kernel`, `memory`, `processor`, `block`) to generate lightweight diagnostic snapshots.
* **Archive Extraction & Ownership Management:** Handle root-owned `.tar.xz` archives safely and recursively adjust user access permissions (`centos:centos`).
* **Navigating Modern Archive Structures:** Interface with `sos` v4.11.2 folder hierarchies, identifying shifted subsystem paths.
* **Custom Performance Scripting:** Develop `/tmp/analyze_performance.sh` to parse CPU metrics, memory availability, and filesystem thresholds.
* **Automation Pipelines:** Construct global analyzer utilities (`/usr/local/bin/sosreport-analyzer`) for streamlined incident response.

---

## 💻 Environment & Prerequisites
* **Operating System:** Red Hat Enterprise Linux / CentOS Linux Release (AWS EC2 Cloud Instance)
* **Diagnostic Utility:** `sos` (version 4.11.2)
* **Shell Environment:** GNU Bash
* **Repository Context:** `redhat-performance-tuning` / `13-system-diagnostics-with-sos-report`
* **System Utilities:** `tar`, `grep`, `awk`, `bc`, `find`, `chown`

---

## 🏗️ Architecture & Directory Structure
When extracted, `sos report` version 4.11.2 arranges diagnostic command outputs, kernel configurations, and system snapshots into structured subdirectories rather than unorganized root files:

```
sosreport-ip-172-31-10-111-2026-10-22-nrsftlw/
├── df -> sos_commands/filesys/df_-al_-x_autofs
├── environment
├── etc/                         # OS release information, system configuration
├── mount -> sos_commands/filesys/mount_-l
├── proc/                        # Process & kernel virtual filesystem snapshots
├── run/                         # Runtime variables and PID mappings
├── sos_commands/               # Command output captures (block, kernel, lvm2, etc.)
├── sos_logs/                   # Execution logs for sos report itself
├── sos_reports/                # HTML and checksum summary reports
├── sys/                         # Kernel sysfs parameter captures
├── var/                         # Captured system logs (dmesg, messages, secure)
└── version.txt                 # Tooling version snapshot
```

---

## 🚀 Step-by-Step Execution Workflow

### Step 1: Targeted Diagnostic Archive Collection
Instead of running a full system dump, we execute `sos report` targeting critical performance subsystems:

```bash
sudo sos report --batch --only-plugins=kernel,memory,processor,block
```
* **`--batch`**: Disables interactive prompts for automated batch execution.
* **`--only-plugins`**: Restricts data gathering to core hardware and kernel subsystems to optimize archive size.

### Step 2: Archive Extraction & Permission Fixing
Extract the generated archive and update directory permissions for non-root analysis:

```bash
# Navigate to the storage directory
cd /home/centos/redhat-performance-tuning/13-system-diagnostics-with-sos-report/sosreports/

# Extract archive
sudo tar -xf sosreport-ip-172-31-10-111-2026-10-22-nrsftlw.tar.xz

# Recursively reassign ownership
sudo chown -R centos:centos sosreport-ip-172-31-10-111-2026-10-22-nrsftlw/
```

### Step 3: Custom Performance Analysis Scripting
To automate metric parsing across extracted reports, we deploy `/tmp/analyze_performance.sh`:

```bash
cat > /tmp/analyze_performance.sh << 'EOF'
#!/bin/bash

echo "=== SOSREPORT PERFORMANCE ANALYSIS ==="
echo "Analysis Date: $(date)"
echo "========================================="

# 1. CPU Analysis
echo -e "\n1. CPU ANALYSIS:"
if [ -f proc/cpuinfo ]; then
    CPU_COUNT=$(grep -c processor proc/cpuinfo)
    echo "   - CPU Cores: $CPU_COUNT"
else
    echo "   - CPU details parsed via sos_commands/processor plugins"
fi

# 2. Memory Analysis
echo -e "\n2. MEMORY ANALYSIS:"
if [ -f proc/meminfo ]; then
    TOTAL_MEM=$(grep MemTotal proc/meminfo | awk '{print $2}')
    AVAILABLE_MEM=$(grep MemAvailable proc/meminfo | awk '{print $2}')
    echo "   - Total Memory: $((TOTAL_MEM/1024)) MB"
    echo "   - Available Memory: $((AVAILABLE_MEM/1024)) MB"
else
    echo "   - Memory info gathered via system logs or profiles"
fi

# 3. Disk Analysis
echo -e "\n3. DISK ANALYSIS:"
if [ -f df ]; then
    echo "   - Filesystem usage summary:"
    cat df | head -10
fi

# 4. Recommendations
echo -e "\n4. RECOMMENDATIONS:"
echo "   - Review disk partitions exceeding 90% utilization"
echo "   - Check kernel logs for hardware or filesystem anomalies"
echo "   - Monitor process memory consumption profiles"
EOF

chmod +x /tmp/analyze_performance.sh
/tmp/analyze_performance.sh
```

---

## 📸 Image Verification & Proof of Execution

For repository asset clarity, the terminal execution screenshots have been mapped and renamed as follows:

| Original Filename | Recommended Repository Path | Description |
| :--- | :--- | :--- |
| `Screenshot (649).png` | `screenshots/01_sosreport_generation.png` | Successful batch generation of a targeted `sos report` (v4.11.2) archive targeting `kernel`, `memory`, `processor`, and `block` plugins. |
| `Screenshot (651).png` | `screenshots/02_performance_analysis_execution.png` | Archive contents inspection (`ls -la`), permission adjustment verification, and execution of `/tmp/analyze_performance.sh`. |

---

### Screenshot 1: Diagnostic Archive Generation
![01_sosreport_generation](screenshots/01_sosreport_generation.png)
*Figure 1: Executing `sudo sos report --batch --only-plugins=kernel,memory,processor,block` on CentOS Linux, producing the compressed archive `/var/tmp/sosreport-ip-172-31-10-111-2026-10-22-qkiwqnm.tar.xz`.*

---

### Screenshot 2: Archive Inspection & Script Execution
![02_performance_analysis_execution](screenshots/02_performance_analysis_execution.png)
*Figure 2: Viewing extracted archives in the `sosreports` working directory, navigating into the uncompressed report, and executing the automated performance evaluation script `/tmp/analyze_performance.sh`.*

---

## 🛠️ Advanced Techniques & Automation Pipeline

### Global Analysis Utility (`sosreport-analyzer`)
To facilitate standardized automated audits across support teams, we installed a reusable binary at `/usr/local/bin/sosreport-analyzer`:

```bash
sudo tee /usr/local/bin/sosreport-analyzer << 'EOF'
#!/bin/bash
SOSREPORT_DIR="$1"
[ -z "$SOSREPORT_DIR" ] || [ ! -d "$SOSREPORT_DIR" ] && { echo "Usage: $0 <sosreport_dir>"; exit 1; }

cd "$SOSREPORT_DIR"
echo "=========================="
echo "SOSREPORT ANALYSIS SUMMARY"
echo "=========================="
echo "Report Directory: $(pwd)"
echo "Analysis Time: $(date)"
echo ""

echo "SYSTEM INFORMATION:"
[ -f hostname ] && echo "  Hostname: $(cat hostname)"
[ -f etc/os-release ] && echo "  OS: $(grep PRETTY_NAME etc/os-release | cut -d'"' -f2)"
[ -f uname ] && echo "  Kernel: $(cat uname)"

echo -e "\nPERFORMANCE METRICS:"
if [ -f proc/meminfo ]; then
    TOTAL=$(grep MemTotal proc/meminfo | awk '{print $2}')
    AVAILABLE=$(grep MemAvailable proc/meminfo | awk '{print $2}')
    USED_PERCENT=$(echo "scale=1; (($TOTAL - $AVAILABLE) * 100) / $TOTAL" | bc 2>/dev/null || echo "0")
    echo "  Memory Usage: ${USED_PERCENT}% of $((TOTAL/1024/1024))GB"
fi
EOF

sudo chmod +x /usr/local/bin/sosreport-analyzer
```

---

## 💡 Best Practices & Troubleshooting

1. **Profile vs. Plugin Distinction (`sos` v4.11.2):**
   * Generic category names like `performance` or `networking` act as **Profiles**.
   * Specific modules like `kernel`, `processor`, `memory`, or `block` act as **Plugins**.
   * Command usage: Use `--profile=storage` or `--only-plugins=kernel,memory`.

2. **Handling Archive Extraction Errors:**
   * Running `tar -xf sosreport-*.tar.xz` while **inside** an extracted directory causes file lookup failures. Always execute extraction commands from the parent directory where the archive resides.

3. **Data Privacy & Obfuscation:**
   * When sending diagnostic bundles to third-party vendors, append the `--obfuscate` flag to anonymize hostnames, IP addresses, and MAC addresses throughout the logs.

---

## 🏁 Conclusion
In this lab, we successfully generated, extracted, and analyzed system diagnostics using **`sos report` version 4.11.2** on CentOS/RHEL. We navigated modern nested directory structures, resolved root ownership boundaries, and engineered automated shell parsers to extract critical hardware and performance metrics. These methodologies establish a foundation for enterprise Linux troubleshooting, incident post-mortems, and proactive system health auditing.