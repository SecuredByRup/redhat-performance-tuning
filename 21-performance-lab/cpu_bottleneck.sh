#!/bin/bash
echo "Starting CPU stress... Press Ctrl+C to stop."
for i in {1..4}; do
    (while true; do echo "scale=5000; 4*a(1)" | bc -l > /dev/null; done) &
done
trap 'kill $(jobs -p); echo "Stopped CPU stress."; exit' INT
wait
