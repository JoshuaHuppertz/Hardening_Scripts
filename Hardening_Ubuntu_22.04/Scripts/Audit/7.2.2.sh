#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.2"

# Initialize result variable
l_output=""

# Check for users with empty passwords
l_check_output=$(awk -F: '($2 == "") { print $1 " does not have a password" }' /etc/shadow)

# Check if there is any output from the command
if [ -z "$l_check_output" ]; then
    l_output="- All users have set a password."
else
    l_output="- The following users do not have a password:\n$l_check_output"
fi

# Check the result and output it
if [ -z "$l_check_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure of the check:$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally: Output result to the console
#echo -e "$RESULT"
