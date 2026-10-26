#!/usr/bin/env python3
import sys

def analyze_syscount_output(filename):
    print("=== System Call Analysis ===")

    with open(filename, 'r') as f:
        lines = f.readlines()

    summary_started = False
    syscalls = []

    for line in lines:
        if "SYSCALL" in line and "COUNT" in line:
            summary_started = True
            continue

        if summary_started and line.strip():
            parts = line.strip().split()
            if len(parts) >= 2:
                try:
                    count = int(parts[1])
                    syscall = parts[0]
                    syscalls.append((syscall, count))
                except ValueError:
                    continue

    if not syscalls:
        print("No syscall data found. Ensure syscount ran and produced output.")
        return

    syscalls.sort(key=lambda x: x[1], reverse=True)

    print("Top 10 System Calls:")
    print(f"{'Syscall':<15} {'Count':<10} {'Percentage':<10}")
    print("-" * 35)

    total_calls = sum(count for _, count in syscalls)

    for syscall, count in syscalls[:10]:
        percentage = (count / total_calls) * 100 if total_calls > 0 else 0
        print(f"{syscall:<15} {count:<10} {percentage:.2f}%")

    print(f"\nTotal system calls: {total_calls}")

    print("\n=== Performance Insights ===")
    high_io_calls = ['read', 'write', 'open', 'close', 'stat', 'fstat']
    network_calls = ['socket', 'connect', 'sendto', 'recvfrom']

    io_total = sum(count for syscall, count in syscalls if syscall in high_io_calls)
    network_total = sum(count for syscall, count in syscalls if syscall in network_calls)

    print(f"I/O related calls: {io_total} ({(io_total / total_calls) * 100:.2f}%)")
    print(f"Network related calls: {network_total} ({(network_total / total_calls) * 100:.2f}%)")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze_syscalls.py <syscount_output_file>")
        sys.exit(1)

    analyze_syscount_output(sys.argv[1])
