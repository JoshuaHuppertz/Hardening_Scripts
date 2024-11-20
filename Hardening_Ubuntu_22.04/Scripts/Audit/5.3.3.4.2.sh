#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.4.2"

# Initialize output variable
output=""

# Function to check remember settings
CHECK_REMEMBER() {
    # Check for pam_unix.so settings in various PAM files
    remember_check=$(grep -PH -- '^\h*[^#\n\r]+\h+pam_unix\.so\b' /etc/pam.d/common-{password,auth,account,session,session-noninteractive} | grep -Pv -- '\bremember=\d+\b')

    # Prepare output based on checks
    if [ -n "$remember_check" ]; then
        output+="Found pam_unix.so settings without remember:\n$remember_check\n"
    else
        output+="Found pam_unix.so settings with remember (does NOT meet local site policy).\n"
    fi
}

# Perform the check
CHECK_REMEMBER

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "Found pam_unix.so settings with remember"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
echo -e "$RESULT"
