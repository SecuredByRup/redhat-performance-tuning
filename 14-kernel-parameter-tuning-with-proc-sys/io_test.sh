#!/bin/bash

echo "=== I/O Performance Test ==="
echo "Current dirty page settings:"
echo "vm.dirty_ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "vm.dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo ""

mkdir -p /tmp/io_test
cd /tmp/io_test

echo "Testing write performance..."
time dd if=/dev/zero of=test_file bs=1M count=100 2>&1

echo ""
echo "Testing read performance..."
sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
time dd if=test_file of=/dev/null bs=1M 2>&1

echo ""
echo "Testing random I/O performance..."
if command -v fio &> /dev/null; then
    fio --name=random-rw --ioengine=posixaio --rw=randrw --bs=4k --size=100M --numjobs=1 --runtime=15 --group_reporting
else
    echo "fio not available, using dd random I/O test"
    time dd if=/dev/urandom of=random_test bs=4k count=1000 2>&1
fi

rm -f test_file random_test
cd /
rmdir /tmp/io_test
