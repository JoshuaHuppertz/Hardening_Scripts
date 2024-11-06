#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.7.4"

# Initialize output variable
l_output=""
l_noexec_check=""

# Check if /var/log/audit is mounted
l_var_log_audit_check=$(findmnt -kn /var/log/audit)

# Verify if /var/log/audit is mounted
if [ -n "$l_var_log_audit_check" ]; then
    # Check if the noexec option is set
    l_noexec_check=$(findmnt -kn /var/log/audit | grep -v 'noexec')

    # Verify if the noexec option is present
    if [ -z "$l_noexec_check" ]; then
        l_output+="\n- The noexec option is set for /var/log/audit."
    else
        l_output+="\n- The noexec option is NOT set for /var/log/audit."
    fi
else
    l_output+="\n- /var/log/audit is NOT mounted."
fi

# Prepare result report
if [[ "$l_output" == *"is NOT set for /var/log/audit."* ]] || [[ "$l_output" == *"is NOT mounted."* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally, print results to console for verification (can be commented out)
#echo -e "$RESULT"
