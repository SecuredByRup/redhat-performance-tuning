#!/bin/bash

REPORT_FILE="./pcp_comprehensive_report_$(date +%Y%m%d_%H%M%S).html"

cat > "$REPORT_FILE" << 'HTML_START'
<!DOCTYPE html>
<html>
<head>
    <title>PCP Performance Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>PCP Performance Analysis Report</h1>
        <p>Generated on cluster nodes via automated tooling</p>
    </div>
HTML_START

echo '<div class="section"><h2>Current Performance Metrics Table</h2><table><tr><th>Host</th><th>CPU User %</th><th>CPU System %</th><th>Memory Used (MB)</th><th>Load Average</th></tr>' >> "$REPORT_FILE"

HOSTS=("localhost" "target-1" "target-2")
for host in "${HOSTS[@]}"; do
    cpu_user=$(pminfo -h "$host" -f kernel.all.cpu.user 2>/dev/null | grep value | awk '{print $2}' || echo "N/A")
    cpu_sys=$(pminfo -h "$host" -f kernel.all.cpu.sys 2>/dev/null | grep value | awk '{print $2}' || echo "N/A")
    mem_used=$(pminfo -h "$host" -f mem.util.used 2>/dev/null | grep value | awk '{print int($2/1024/1024)}' || echo "N/A")
    load_avg=$(pminfo -h "$host" -f kernel.all.load 2>/dev/null | grep value | awk '{print $2}' || echo "N/A")
    
    echo "        <tr><td>$host</td><td>$cpu_user</td><td>$cpu_sys</td><td>$mem_used</td><td>$load_avg</td></tr>" >> "$REPORT_FILE"
done

echo '    </table></div></body></html>' >> "$REPORT_FILE"

echo "Comprehensive HTML report generated: $REPORT_FILE"
