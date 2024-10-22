#!/bin/bash

echo "Starting iptables and iptables-persistent installation audit..."

# Define a status flag
audit_passed=true

# Check if iptables is installed
echo "Verifying if iptables is installed..."
if dpkg-query -s iptables &>/dev/null; then
    echo "PASS: iptables is installed."
else
    echo "FAIL: iptables is NOT installed."
    audit_passed=false
fi

# Check if iptables-persistent is installed
echo "Verifying if iptables-persistent is installed..."
if dpkg-query -s iptables-persistent &>/dev/null; then
    echo "PASS: iptables-persistent is installed."
else
    echo "FAIL: iptables-persistent is NOT installed."
    audit_passed=false
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: Both iptables and iptables-persistent are installed."
else
    echo "Audit failed: One or more packages are missing."
fi
