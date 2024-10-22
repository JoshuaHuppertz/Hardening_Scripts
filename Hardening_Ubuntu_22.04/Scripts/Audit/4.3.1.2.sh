#!/bin/bash

echo "Starting nftables installation audit..."

# Define a status flag
audit_passed=true

# Check if nftables is installed
echo "Verifying if nftables is installed..."
if dpkg-query -s nftables &>/dev/null; then
    echo "FAIL: nftables is installed."
    audit_passed=false
else
    echo "PASS: nftables is NOT installed."
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: nftables is not installed as expected."
else
    echo "Audit failed: nftables is installed, but it should not be."
fi
