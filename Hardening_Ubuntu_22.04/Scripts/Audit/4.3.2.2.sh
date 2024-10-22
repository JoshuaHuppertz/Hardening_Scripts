#!/bin/bash

echo "Starting iptables rule audit..."

# Define a status flag
audit_passed=true

# Check for INPUT chain rules
echo "Verifying INPUT chain rules..."
input_rules=$(iptables -L INPUT -v -n)

# Verify rule to accept traffic on loopback interface (lo)
if echo "$input_rules" | grep -qE "ACCEPT .* lo"; then
    echo "PASS: INPUT chain has rule to ACCEPT traffic on loopback interface."
else
    echo "FAIL: INPUT chain is missing rule to ACCEPT traffic on loopback interface."
    audit_passed=false
fi

# Verify rule to drop traffic from 127.0.0.0/8
if echo "$input_rules" | grep -qE "DROP .* 127.0.0.0/8"; then
    echo "PASS: INPUT chain has rule to DROP traffic from 127.0.0.0/8."
else
    echo "FAIL: INPUT chain is missing rule to DROP traffic from 127.0.0.0/8."
    audit_passed=false
fi

# Check for OUTPUT chain rules
echo "Verifying OUTPUT chain rules..."
output_rules=$(iptables -L OUTPUT -v -n)

# Verify rule to accept outgoing traffic to loopback interface (lo)
if echo "$output_rules" | grep -qE "ACCEPT .* lo"; then
    echo "PASS: OUTPUT chain has rule to ACCEPT outgoing traffic to loopback interface."
else
    echo "FAIL: OUTPUT chain is missing rule to ACCEPT outgoing traffic to loopback interface."
    audit_passed=false
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: Required rules are present in the INPUT and OUTPUT chains."
else
    echo "Audit failed: One or more required rules are missing from the INPUT or OUTPUT chains."
fi
