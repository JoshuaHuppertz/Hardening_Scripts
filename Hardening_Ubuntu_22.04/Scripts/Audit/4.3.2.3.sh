#!/bin/bash

echo "Starting iptables outbound and established connections audit..."

# Define a status flag
audit_passed=true

# Get the current iptables rules
iptables_rules=$(iptables -L -v -n)

# Check for new outbound connections
echo "Verifying rules for new outbound connections..."
if echo "$iptables_rules" | grep -qE "ACCEPT .* ct state NEW"; then
    echo "PASS: Rule for new outbound connections found."
else
    echo "FAIL: Rule for new outbound connections NOT found."
    audit_passed=false
fi

# Check for established connections
echo "Verifying rules for established connections..."
if echo "$iptables_rules" | grep -qE "ACCEPT .* ct state ESTABLISHED"; then
    echo "PASS: Rule for established connections found."
else
    echo "FAIL: Rule for established connections NOT found."
    audit_passed=false
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All rules for new and established outbound connections are present."
else
    echo "Audit failed: One or more rules for new or established outbound connections are missing."
fi
