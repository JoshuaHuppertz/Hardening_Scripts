#!/bin/bash

echo "Starting loopback interface configuration audit..."

# Define a status flag
audit_passed=true

# Check if the loopback interface is configured to accept network traffic
echo "Verifying loopback interface is configured to accept network traffic..."
lo_accept=$(nft list ruleset | awk '/hook input/,/}/' | grep 'iif "lo" accept')
if [[ -n "$lo_accept" ]]; then
    echo "PASS: Loopback interface is configured to accept network traffic."
else
    echo "FAIL: Loopback interface is NOT configured to accept network traffic."
    audit_passed=false
fi

# Verify network traffic from IPv4 loopback interface is configured to drop
echo "Verifying IPv4 loopback traffic is configured to drop..."
ipv4_drop=$(nft list ruleset | awk '/hook input/,/}/' | grep 'ip saddr 127.0.0.0/8')
if [[ -n "$ipv4_drop" ]]; then
    echo "PASS: IPv4 loopback traffic is configured to drop."
else
    echo "FAIL: IPv4 loopback traffic is NOT configured to drop."
    audit_passed=false
fi

# Check if IPv6 is enabled
if [ -f /proc/net/if_inet6 ]; then
    echo "IPv6 is enabled. Verifying IPv6 loopback traffic is configured to drop..."
    ipv6_drop=$(nft list ruleset | awk '/hook input/,/}/' | grep 'ip6 saddr ::1')
    if [[ -n "$ipv6_drop" ]]; then
        echo "PASS: IPv6 loopback traffic is configured to drop."
    else
        echo "FAIL: IPv6 loopback traffic is NOT configured to drop."
        audit_passed=false
    fi
else
    echo "IPv6 is not enabled, skipping IPv6 check."
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All configurations are correct."
else
    echo "Audit failed: One or more configurations are incorrect."
fi
