#!/bin/bash

echo "Starting IPv6 audit for ip6tables rules..."

# Define a status flag
audit_passed=true

# Get ip6tables rules for INPUT chain
echo "Verifying INPUT chain rules..."
input_rules=$(ip6tables -L INPUT -v -n)

# Check for the expected INPUT chain rules
if echo "$input_rules" | grep -q "Chain INPUT (policy DROP"; then
    echo "PASS: INPUT chain policy is DROP."
else
    echo "FAIL: INPUT chain policy is NOT DROP."
    audit_passed=false
fi

if echo "$input_rules" | grep -q "ACCEPT all lo * ::/0 ::/0"; then
    echo "PASS: Rule for accepting all traffic on loopback interface is present."
else
    echo "FAIL: Rule for accepting all traffic on loopback interface is NOT present."
    audit_passed=false
fi

if echo "$input_rules" | grep -q "DROP all * * ::1 ::/0"; then
    echo "PASS: Rule for dropping all traffic from ::1 is present."
else
    echo "FAIL: Rule for dropping all traffic from ::1 is NOT present."
    audit_passed=false
fi

# Get ip6tables rules for OUTPUT chain
echo "Verifying OUTPUT chain rules..."
output_rules=$(ip6tables -L OUTPUT -v -n)

# Check for the expected OUTPUT chain rules
if echo "$output_rules" | grep -q "Chain OUTPUT (policy DROP"; then
    echo "PASS: OUTPUT chain policy is DROP."
else
    echo "FAIL: OUTPUT chain policy is NOT DROP."
    audit_passed=false
fi

if echo "$output_rules" | grep -q "ACCEPT all * lo ::/0 ::/0"; then
    echo "PASS: Rule for accepting all traffic from loopback interface is present."
else
    echo "FAIL: Rule for accepting all traffic from loopback interface is NOT present."
    audit_passed=false
fi

# If any chain rule failed, check if IPv6 is enabled
if [ "$audit_passed" = false ]; then
    echo "Checking if IPv6 is enabled on the system..."

    # Check if IPv6 is enabled
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        echo " - IPv6 is enabled on the system."
    else
        echo " - IPv6 is not enabled on the system."
    fi
else
    echo "All ip6tables rules are correctly configured."
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All expected ip6tables rules are present."
else
    echo "Audit failed: One or more expected ip6tables rules are missing."
fi
