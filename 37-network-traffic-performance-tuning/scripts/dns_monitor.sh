#!/bin/bash

echo "DNS Performance Monitoring"
echo "========================="

DOMAINS=("google.com" "github.com" "stackoverflow.com" "redhat.com" "ubuntu.com")

echo "Testing DNS resolution times..."
for domain in "${DOMAINS[@]}"; do
    echo -n "Testing $domain: "
    dig +short +time=1 +tries=1 $domain > /dev/null
    if [ $? -eq 0 ]; then
        time_result=$(dig $domain | grep "Query time" | awk '{print $4}')
        echo "${time_result}ms"
    else
        echo "Failed"
    fi
done

echo ""
echo "DNS Cache Statistics:"
systemd-resolve --statistics
