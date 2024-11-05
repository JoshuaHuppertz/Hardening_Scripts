#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.6.4"

# Initialize output variables
l_output=""
l_output2=""

# Function to check /etc/motd permissions and ownership
check_motd_permissions() {
    echo -e "\n- Checking permissions and ownership of /etc/motd"
    
    # Check if /etc/motd exists
    if [ -e /etc/motd ]; then
        # Get the file status
        motd_status=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /etc/motd)
        echo "$motd_status" >> "$RESULT_DIR/motd_permissions.txt"
        
        # Check if permissions are 644 or more restrictive and owner is root
        if [[ $(stat -c "%a" /etc/motd) -le 644 && $(stat -c "%u" /etc/motd) -eq 0 && $(stat -c "%g" /etc/motd) -eq 0 ]]; then
            l_output="$l_output\n - /etc/motd has correct permissions and ownership:\n$motd_status"
        else
            l_output2="$l_output2\n - /etc/motd permissions or ownership are incorrect:\n$motd_status"
        fi
    else
        l_output="$l_output\n - /etc/motd does not exist."
    fi
}

# Run the check
check_motd_permissions

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