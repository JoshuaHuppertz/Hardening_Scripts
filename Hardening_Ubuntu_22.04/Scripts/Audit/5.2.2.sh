#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.2"

# Initialize output variables
l_output=""
l_output2=""

# Function to check sudo configuration for use_pty
CHECK_USE_PTY() {
    # Check if Defaults use_pty is set
    if grep -rPi -- '^\h*Defaults\h+([^#\n\r]+,)?use_pty(,\h*\h+\h*)*\h*(#.*)?$' /etc/sudoers*; then
        l_output+="\n - /etc/sudoers: Defaults use_pty is set."
    else
        l_output2+="\n - /etc/sudoers: Defaults use_pty is not set."
    fi

    # Check if Defaults !use_pty is not set
    if grep -rPi -- '^\h*Defaults\h+([^#\n\r]+,)?!use_pty(,\h*\h+\h*)*\h*(#.*)?$' /etc/sudoers*; then
        l_output2+="\n - /etc/sudoers: Defaults !use_pty is set, which is not allowed."
    fi
}

# Perform the check
CHECK_USE_PTY

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - * Reasons for audit failure * :$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally print the result to the console
echo -e "$RESULT"
