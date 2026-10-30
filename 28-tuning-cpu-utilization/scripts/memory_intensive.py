#!/usr/bin/env python3
import time
import sys
import os

def memory_intensive_task(duration=30):
    """Memory-intensive task with frequent allocations"""
    print(f"PID: {os.getpid()}")
    print(f"Running memory-intensive task for {duration} seconds")
    
    start_time = time.time()
    data_arrays = []
    
    while time.time() - start_time < duration:
        # Create and manipulate large arrays
        array = list(range(100000))
        array.sort(reverse=True)
        data_arrays.append(array[:1000])  # Keep some data
        
        # Cleanup periodically
        if len(data_arrays) > 50:
            data_arrays = data_arrays[-25:]
        
        if int(time.time() - start_time) % 5 == 0:
            elapsed = int(time.time() - start_time)
            if elapsed > 0:
                print(f"Elapsed: {elapsed}s, Arrays: {len(data_arrays)}")
                time.sleep(0.1)
    
    print(f"Task completed. Final arrays: {len(data_arrays)}")

if __name__ == "__main__":
    duration = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    memory_intensive_task(duration)
