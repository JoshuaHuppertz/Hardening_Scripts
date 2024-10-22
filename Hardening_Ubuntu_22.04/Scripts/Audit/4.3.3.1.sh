#!/bin/bash

echo "Starting IPv6 audit..."

# Define a status flag
audit_passed=true

# Check ip6tables rules
echo "Verifying ip6tables policies for INPUT, OUTPUT, and FORWARD chains..."
ip6tables_rules=$(ip6tables -L)

# Check INPUT chain policy
if echo "$ip6tables_rules" | grep -q "Chain INPUT (policy DROP\|REJECT)"; then
    echo "PASS: INPUT chain policy is set to DROP or REJECT."
else
    echo "FAIL: INPUT chain policy is NOT set to DROP or REJECT."
    audit_passed=false
fi

# Check FORWARD chain policy
if echo "$ip6tables_rules" | grep -q "Chain FORWARD (policy DROP\|REJECT)"; then
    echo "PASS: FORWARD chain policy is set to DROP or REJECT."
else
    echo "FAIL: FORWARD chain policy is NOT set to DROP or REJECT."
    audit_passed=false
fi

# Check OUTPUT chain policy
if echo "$ip6tables_rules" | grep -q "Chain OUTPUT (policy DROP\|REJECT)"; then
    echo "PASS: OUTPUT chain policy is set to DROP or REJECT."
else
    echo "FAIL: OUTPUT chain policy is NOT set to DROP or REJECT."
    audit_passed=false
fi

# If any chain policy failed, check if IPv6 is enabled
if [ "$audit_passed" = false ]; then
    echo "Checking if IPv6 is enabled on the system..."

    # Check if IPv6 is enabled
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        echo " - IPv6 is enabled on the system."
    else
        echo " - IPv6 is not enabled on the system."
    fi
else
    echo "All ip6tables policies are correctly configured."
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All policies for INPUT, OUTPUT, and FORWARD chains are set correctly."
else
    echo "Audit failed: One or more policies are incorrectly configured."
fi
