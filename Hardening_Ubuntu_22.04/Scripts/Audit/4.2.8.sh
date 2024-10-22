#!/bin/bash

echo "Starting base chain policy audit..."

# Define a status flag
audit_passed=true

# Expected policy for each chain (DROP)
expected_policy="policy drop"

# Check the input chain policy
echo "Verifying 'input' chain policy..."
input_policy=$(nft list ruleset | grep 'hook input')
if echo "$input_policy" | grep -q "$expected_policy"; then
    echo "PASS: 'input' chain has policy DROP."
else
    echo "FAIL: 'input' chain does NOT have policy DROP."
    audit_passed=false
fi

# Check the forward chain policy
echo "Verifying 'forward' chain policy..."
forward_policy=$(nft list ruleset | grep 'hook forward')
if echo "$forward_policy" | grep -q "$expected_policy"; then
    echo "PASS: 'forward' chain has policy DROP."
else
    echo "FAIL: 'forward' chain does NOT have policy DROP."
    audit_passed=false
fi

# Check the output chain policy
echo "Verifying 'output' chain policy..."
output_policy=$(nft list ruleset | grep 'hook output')
if echo "$output_policy" | grep -q "$expected_policy"; then
    echo "PASS: 'output' chain has policy DROP."
else
    echo "FAIL: 'output' chain does NOT have policy DROP."
    audit_passed=false
fi

# Final audit result
if [ "$audit_passed" = true ]; then
    echo "Audit passed: All base chains have policy DROP."
else
    echo "Audit failed: One or more base chains do not have policy DROP."
fi
