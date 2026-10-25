#!/usr/bin/env python3
import os
import sys
import json
import statistics
from datetime import datetime
from collections import defaultdict
import re

class PerformanceReportGenerator:
    def __init__(self):
        self.report = {
            'timestamp': datetime.now().isoformat(),
            'system_calls': {},
            'dns_performance': {},
            'performance_issues': [],
            'recommendations': []
        }

    def analyze_syscount_data(self, filename):
        """Analyze syscount output file"""
        if not os.path.exists(filename):
            print(f"Warning: {filename} not found, skipping syscall analysis")
            return

        print(f"Analyzing system call data from {filename}...")

        with open(filename, 'r') as f:
            content = f.read()

        syscalls = {}
        for line in content.split('\n'):
            if line.strip() and not line.strip().startswith('SYSCALL') and not line.startswith('Tracing') and not line.startswith('['):
                parts = line.strip().split()
                if len(parts) >= 2:
                    try:
                        syscall = parts[0]
                        count = int(parts[1])
                        syscalls[syscall] = syscalls.get(syscall, 0) + count
                    except (ValueError, IndexError):
                        continue

        if not syscalls:
            return

        self.report['system_calls'] = {
            'total_calls': sum(syscalls.values()),
            'unique_syscalls': len(syscalls),
            'top_syscalls': dict(sorted(syscalls.items(), key=lambda x: x[1], reverse=True)[:10])
        }

        io_calls = sum(count for syscall, count in syscalls.items()
                        if syscall in ['read', 'write', 'open', 'close', 'stat', 'fstat'])

        if io_calls > 10000:
            self.report['performance_issues'].append({
                'type': 'high_io',
                'description': f'High I/O activity detected: {io_calls} I/O system calls',
                'severity': 'medium'
            })

    def analyze_dns_latency_data(self, filename):
        """Analyze gethostlatency output file"""
        if not os.path.exists(filename):
            print(f"Warning: {filename} not found, skipping DNS analysis")
            return

        print(f"Analyzing DNS latency data from {filename}...")

        latencies = []
        hosts = defaultdict(list)

        with open(filename, 'r') as f:
            for line in f:
                match = re.search(r'(\d+:\d+:\d+)\s+(\d+)\s+(\S+)\s+([\d.]+)\s+(\S+)', line)
                if match:
                    _, _, _, latency, host = match.groups()
                    latency_val = float(latency)
                    latencies.append(latency_val)
                    hosts[host].append(latency_val)

        if not latencies:
            return

        avg_latency = statistics.mean(latencies)

        self.report['dns_performance'] = {
            'total_queries': len(latencies),
            'average_latency': avg_latency,
            'median_latency': statistics.median(latencies),
            'max_latency': max(latencies),
            'min_latency': min(latencies),
            'slow_queries_count': len([l for l in latencies if l > 100]),
            'hosts_queried': len(hosts)
        }

        slow_queries = [l for l in latencies if l > 100]
        if slow_queries:
            self.report['performance_issues'].append({
                'type': 'slow_dns',
                'description': f'{len(slow_queries)} DNS queries took >100ms',
                'severity': 'medium' if len(slow_queries) < 10 else 'high'
            })

        very_slow_queries = [l for l in latencies if l > 500]
        if very_slow_queries:
            self.report['performance_issues'].append({
                'type': 'very_slow_dns',
                'description': f'{len(very_slow_queries)} DNS queries took >500ms',
                'severity': 'high'
            })

    def generate_recommendations(self):
        """Generate performance recommendations based on analysis"""
        recommendations = []

        if self.report['system_calls']:
            total_calls = self.report['system_calls'].get('total_calls', 0)
            if total_calls > 50000:
                recommendations.append({
                    'category': 'system_calls',
                    'recommendation': 'Consider optimizing application to reduce system call frequency, for example by buffering I/O or batching operations',
                    'priority': 'medium'
                })

            top_syscalls = self.report['system_calls'].get('top_syscalls', {})
            if top_syscalls.get('futex', 0) > 5000:
                recommendations.append({
                    'category': 'system_calls',
                    'recommendation': 'High futex counts suggest lock contention; profile thread synchronization',
                    'priority': 'medium'
                })

        if self.report['dns_performance']:
            avg_latency = self.report['dns_performance'].get('average_latency', 0)
            if avg_latency > 100:
                recommendations.append({
                    'category': 'dns',
                    'recommendation': 'Average DNS latency exceeds 100ms; consider a local caching resolver such as systemd-resolved or dnsmasq',
                    'priority': 'high'
                })
            elif avg_latency > 50:
                recommendations.append({
                    'category': 'dns',
                    'recommendation': 'DNS latency is moderate; monitor trends and verify resolver configuration',
                    'priority': 'low'
                })

            slow_count = self.report['dns_performance'].get('slow_queries_count', 0)
            if slow_count > 0:
                recommendations.append({
                    'category': 'dns',
                    'recommendation': 'Investigate specific hosts with repeated slow resolutions for upstream DNS or network path issues',
                    'priority': 'medium'
                })

        if not recommendations:
            recommendations.append({
                'category': 'general',
                'recommendation': 'No significant performance issues detected during this monitoring window',
                'priority': 'info'
            })

        self.report['recommendations'] = recommendations

    def save_report(self, output_file='performance_report.json'):
        with open(output_file, 'w') as f:
            json.dump(self.report, f, indent=2)
        print(f"\nReport saved to {output_file}")

    def print_summary(self):
        print("\n=== Performance Report Summary ===")
        print(f"Generated: {self.report['timestamp']}")

        if self.report['system_calls']:
            print(f"\nTotal system calls: {self.report['system_calls'].get('total_calls', 0)}")
            print(f"Unique syscalls: {self.report['system_calls'].get('unique_syscalls', 0)}")

        if self.report['dns_performance']:
            print(f"\nTotal DNS queries: {self.report['dns_performance'].get('total_queries', 0)}")
            print(f"Average DNS latency: {self.report['dns_performance'].get('average_latency', 0):.2f} ms")

        print(f"\nPerformance issues found: {len(self.report['performance_issues'])}")
        for issue in self.report['performance_issues']:
            print(f"  [{issue['severity'].upper()}] {issue['description']}")

        print(f"\nRecommendations: {len(self.report['recommendations'])}")
        for rec in self.report['recommendations']:
            print(f"  [{rec['priority'].upper()}] {rec['recommendation']}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 generate_performance_report.py <syscount_output_file> <gethostlatency_output_file>")
        sys.exit(1)

    syscount_file = sys.argv[1]
    dns_file = sys.argv[2]

    generator = PerformanceReportGenerator()
    generator.analyze_syscount_data(syscount_file)
    generator.analyze_dns_latency_data(dns_file)
    generator.generate_recommendations()
    generator.print_summary()
    generator.save_report('performance_report.json')

if __name__ == "__main__":
    main()
