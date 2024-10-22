#!/bin/bash

echo "Starting audit for ip6tables rules related to new outbound and established connections..."

# Define a status flag
audit_passed=true

# Get the current ip6tables rules
ip6tables_rules=$(ip6tables -L -v -n)

# Check for new outbound and established connection rules
echo "$ip6tables_rules" | grep -q "Chain OUTPUT"  # Ensure OUTPUT chain exists
if echo "$ip6tables_rules" | grep -q "ACCEPT.*ct state established"; then
    echo "PASS: Rule for accepting established connections is present in OUTPUT chain."
else
    echo "FAIL: Rule for accepting established connections is NOT present in OUTPUT chain."
    audit_passed=false
fi

if echo "$ip6tables_rules" | grep -q "ACCEPT.*ct state new"; then
    echo "PASS: Rule for accepting new connections is present in OUTPUT chain."
else
    echo "FAIL: Rule for accepting new connections is NOT present in OUTPUT chain."
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
    echo "All necessary ip6tables rules for new and established connections are correctly configured."
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All expected ip6tables rules are present for new outbound and established connections."
else
    echo "Audit failed: One or more expected ip6tables rules for new outbound and established connections are missing."
fi
