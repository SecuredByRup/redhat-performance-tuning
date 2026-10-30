#!/usr/bin/env python3
import time
import sys

def run_simulation():
    print("Starting bounded memory leak simulation...")
    print("Will allocate memory for 15 iterations (~10MB each), then exit.")
    
    leak_storage = []
    chunk_size = 10 * 1024 * 1024  # ~10MB chunks
    
    try:
        for i in range(1, 16):
            # Allocate chunk and retain reference (simulating a leak)
            chunk = bytearray(chunk_size)
            leak_storage.append(chunk)
            print(f"Iteration {i}: Allocated ~{i * 10}MB total")
            time.sleep(1.5)
            
        print("Memory leak simulation finished.")
        print(f"Total allocated before exit: ~{len(leak_storage) * 10}MB")
    except Exception as e:
        print(f"Simulation interrupted: {e}")

if __name__ == "__main__":
    run_simulation()
