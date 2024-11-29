#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.1.2"

# Initialize result variables
l_output=""
l_output2=""

# Check if auditd is enabled
l_enabled_output=$(systemctl is-enabled auditd 2>/dev/null)
if echo "$l_enabled_output" | grep -q '^enabled'; then
    l_output+="\n- auditd is enabled."
else
    l_output2+="\n- auditd is not enabled."
fi

# Check if auditd is active
l_active_output=$(systemctl is-active auditd 2>/dev/null)
if echo "$l_active_output" | grep -q '^active'; then
    l_output+="\n- auditd is active."
else
    l_output2+="\n- auditd is not active."
fi

# Check results and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
echo -e "$RESULT"
