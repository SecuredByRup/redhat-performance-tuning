#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <PID> [signal]"
    echo "Common signals: TERM (15), KILL (9)"
    exit 1
fi

PID=$1
SIGNAL=${2:-TERM}

if ! ps -p $PID > /dev/null 2>&1; then
    echo "Process $PID does not exist"
    exit 1
fi

echo "Sending $SIGNAL signal to process $PID..."
kill -$SIGNAL $PID

sleep 2
if ps -p $PID > /dev/null 2>&1; then
    echo "Process $PID is still running"
    if [ "$SIGNAL" != "KILL" ]; then
        echo "Try force termination: $0 $PID KILL"
    fi
else
    echo "Process $PID terminated successfully"
fi
