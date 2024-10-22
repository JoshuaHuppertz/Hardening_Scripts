#!/bin/bash

echo "Starting nftables service status audit..."

# Check if the nftables service is enabled
echo "Verifying if nftables service is enabled..."
nftables_status=$(systemctl is-enabled nftables)

if [[ "$nftables_status" == "enabled" ]]; then
    echo "PASS: nftables service is enabled."
else
    echo "FAIL: nftables service is NOT enabled. Current status: $nftables_status"
    audit_passed=false
fi

# Final audit result
if [[ "$nftables_status" == "enabled" ]]; then
    echo "Audit passed: nftables service is correctly enabled."
else
    echo "Audit failed: nftables service is not enabled."
fi
