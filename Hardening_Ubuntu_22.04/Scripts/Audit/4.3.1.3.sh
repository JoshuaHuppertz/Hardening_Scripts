#!/bin/bash

echo "Starting ufw audit..."

# Define a status flag
audit_passed=false

# Check if ufw is installed
echo "Verifying if ufw is installed..."
if dpkg-query -s ufw &>/dev/null; then
    echo "ufw is installed."

    # If ufw is installed, check if it is disabled
    echo "Verifying if ufw is disabled..."
    ufw_status=$(ufw status | grep "Status: inactive")
    if [[ -n "$ufw_status" ]]; then
        echo "PASS: ufw is installed but disabled."
        audit_passed=true
    else
        echo "FAIL: ufw is installed and active."
    fi

    # If ufw is installed, also check if it is masked
    echo "Verifying if ufw service is masked..."
    if systemctl is-enabled ufw | grep -q "masked"; then
        echo "PASS: ufw service is masked."
        audit_passed=true
    else
        echo "FAIL: ufw service is not masked."
    fi

else
    echo "PASS: ufw is not installed."
    audit_passed=true
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: ufw is either not installed, disabled, or masked."
else
    echo "Audit failed: ufw is installed and active, and service is not masked."
fi
