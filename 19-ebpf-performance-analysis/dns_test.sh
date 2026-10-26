#!/bin/bash
echo "Starting DNS resolution tests..."

websites=(
    "google.com"
    "github.com"
    "stackoverflow.com"
    "redhat.com"
    "python.org"
)

for site in "${websites[@]}"; do
    echo "Resolving $site..."
    getent ahosts "$site" > /dev/null 2>&1
    nslookup "$site" > /dev/null 2>&1
    sleep 1
done

echo "DNS tests completed"
