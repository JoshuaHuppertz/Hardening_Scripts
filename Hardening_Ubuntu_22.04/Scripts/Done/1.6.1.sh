#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.6.1"

# Initialize output variables
l_output=""
l_output2=""

# Function to check the contents of /etc/motd
check_motd_contents() {
    echo -e "\n- Checking contents of /etc/motd"
    motd_content=$(cat /etc/motd)

    # Verify that the contents match site policy (you can customize this check)
    # For now, we'll just display the contents. You can replace this with actual policy checks.
    echo -e "$motd_content" >> "$RESULT_DIR/motd_contents.txt"

    # Check for unwanted escape sequences
    if grep -E -i "(\\\v|\\\r|\\\m|\\\s|$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g'))" /etc/motd; then
        l_output2="$l_output2\n - Unwanted patterns found in /etc/motd."
    else
        l_output="$l_output\n - No unwanted patterns found in /etc/motd."
    fi
}

# Run the checks
check_motd_contents

# Prepare result report
if [ -z "$l_output2" ]; then
    # PASS: No issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    # FAIL: Issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
