#!/bin/bash

echo "Starting iptables policy audit..."

# Define a status flag
audit_passed=true

# Function to check the policy for a given chain
check_policy() {
    chain="$1"
    policy=$(iptables -L $chain -v -n | grep "Chain $chain" | awk '{print $4}')
    
    if [[ "$policy" == "DROP" || "$policy" == "REJECT" ]]; then
        echo "PASS: $chain chain policy is $policy."
    else
        echo "FAIL: $chain chain policy is not DROP or REJECT (current: $policy)."
        audit_passed=false
    fi
}

# Check policy for INPUT chain
echo "Verifying INPUT chain policy..."
check_policy "INPUT"

# Check policy for FORWARD chain
echo "Verifying FORWARD chain policy..."
check_policy "FORWARD"

# Check policy for OUTPUT chain
echo "Verifying OUTPUT chain policy..."
check_policy "OUTPUT"

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All chain policies are set to DROP or REJECT."
else
    echo "Audit failed: One or more chain policies are not set to DROP or REJECT."
fi
