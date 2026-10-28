#!/bin/bash
echo "Allocating 75% memory pressure... Press Ctrl+C to stop."
stress-ng --vm 2 --vm-bytes 75% --timeout 300s &
STRESS_PID=$!
trap 'kill $STRESS_PID 2>/dev/null; echo "Stopped Memory stress."; exit' INT
wait $STRESS_PID
