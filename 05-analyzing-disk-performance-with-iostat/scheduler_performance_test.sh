#!/bin/bash
# I/O Scheduler Performance Testing Script

if [ $# -ne 1 ]; then
    echo "Usage: $0 <device_name>"
    echo "Example: $0 sda"
    exit 1
fi

DEVICE=$1
TEST_DIR="scheduler_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p $TEST_DIR

SCHEDULERS=$(cat /sys/block/$DEVICE/queue/scheduler | tr -d '[]' | tr ' ' '\n' | grep -v '^$')

echo "Testing I/O schedulers for device: $DEVICE"
echo "Available schedulers: $(echo $SCHEDULERS | tr '\n' ' ')"
echo "Results will be saved in: $TEST_DIR"

run_test() {
    local scheduler=$1
    echo "Testing scheduler: $scheduler"
    
    echo $scheduler > /sys/block/$DEVICE/queue/scheduler
    sleep 2
    
    iostat -x 2 30 > $TEST_DIR/${scheduler}_iostat.log &
    IOSTAT_PID=$!
    
    ./io_workload_generator.sh mixed > $TEST_DIR/${scheduler}_workload.log 2>&1
    
    kill $IOSTAT_PID 2>/dev/null
    
    echo "Scheduler: $scheduler" > $TEST_DIR/${scheduler}_summary.txt
    echo "Average utilization: $(awk '/^[a-z]/ {sum+=$NF; count++} END {if(count>0) print sum/count "%"}' $TEST_DIR/${scheduler}_iostat.log)" >> $TEST_DIR/${scheduler}_summary.txt
    echo "Average await: $(awk '/^[a-z]/ {sum+=$(NF-1); count++} END {if(count>0) print sum/count "ms"}' $TEST_DIR/${scheduler}_iostat.log)" >> $TEST_DIR/${scheduler}_summary.txt
    
    echo "Test completed for $scheduler"
    sleep 5
}

for scheduler in $SCHEDULERS; do
    run_test $scheduler
done

echo "Performance testing completed! Results directory: $TEST_DIR"
