#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.1.2"

# Initialize output variables
l_output=""
l_output2=""

# Check if iptables-persistent is installed
if dpkg-query -s iptables-persistent &>/dev/null; then
    l_output2=" - iptables-persistent is installed"
else
    l_output=" - iptables-persistent is not installed"
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit check
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally print the result to the console
echo -e "$RESULT"