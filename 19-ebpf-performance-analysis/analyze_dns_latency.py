#!/usr/bin/env python3
import sys
import re
from collections import defaultdict
import statistics

def parse_gethostlatency_output(filename):
    print("=== DNS Latency Analysis ===")

    latencies = []
    host_latencies = defaultdict(list)
    pid_latencies = defaultdict(list)

    with open(filename, 'r') as f:
        for line in f:
            match = re.search(r'(\d+:\d+:\d+)\s+(\d+)\s+(\S+)\s+([\d.]+)\s+(\S+)', line)
            if match:
                _, pid, comm, latency, host = match.groups()
                latency_ms = float(latency)

                latencies.append(latency_ms)
                host_latencies[host].append(latency_ms)
                pid_latencies[f"{pid}({comm})"].append(latency_ms)

    if not latencies:
        print("No DNS latency data found in the file.")
        return

    print(f"Total DNS resolutions: {len(latencies)}")
    print(f"Average latency: {statistics.mean(latencies):.2f} ms")
    print(f"Median latency: {statistics.median(latencies):.2f} ms")
    print(f"Min latency: {min(latencies):.2f} ms")
    print(f"Max latency: {max(latencies):.2f} ms")

    if len(latencies) > 1:
        print(f"Standard deviation: {statistics.stdev(latencies):.2f} ms")

    print("\n=== Latency Distribution ===")
    ranges = [(0, 10), (10, 50), (50, 100), (100, 500), (500, float('inf'))]
    range_labels = ["0-10ms", "10-50ms", "50-100ms", "100-500ms", ">500ms"]

    for (min_lat, max_lat), label in zip(ranges, range_labels):
        count = sum(1 for lat in latencies if min_lat <= lat < max_lat)
        percentage = (count / len(latencies)) * 100
        print(f"{label:<10}: {count:>3} ({percentage:>5.1f}%)")

    print("\n=== Slowest Hosts (Average Latency) ===")
    host_avg_latencies = [(host, statistics.mean(lats)) for host, lats in host_latencies.items()]
    host_avg_latencies.sort(key=lambda x: x[1], reverse=True)

    for host, avg_lat in host_avg_latencies[:10]:
        count = len(host_latencies[host])
        print(f"{host:<25}: {avg_lat:>6.2f} ms (n={count})")

    print("\n=== Process DNS Activity ===")
    pid_sorted = sorted(pid_latencies.items(), key=lambda x: len(x[1]), reverse=True)

    for pid_comm, lats in pid_sorted[:5]:
        avg_lat = statistics.mean(lats)
        print(f"{pid_comm:<20}: {len(lats):>3} lookups, avg {avg_lat:>6.2f} ms")

    print("\n=== Performance Warnings ===")
    slow_resolutions = [lat for lat in latencies if lat > 100]
    if slow_resolutions:
        print(f"WARNING: {len(slow_resolutions)} DNS resolutions took >100ms")
        print(f"Slowest resolution: {max(slow_resolutions):.2f} ms")
    else:
        print("All DNS resolutions completed in reasonable time")

    very_slow_resolutions = [lat for lat in latencies if lat > 500]
    if very_slow_resolutions:
        print(f"CRITICAL: {len(very_slow_resolutions)} DNS resolutions took >500ms")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze_dns_latency.py <gethostlatency_output_file>")
        sys.exit(1)

    parse_gethostlatency_output(sys.argv[1])
