#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.4"

# Initialize output variables
l_output=""
l_output2=""

# Function to check SSHD configuration for allow/deny users/groups
CHECK_SSHD_CONFIG() {
    local config_output
    config_output=$(sshd -T 2>/dev/null | grep -Pi -- '^\h*(allow|deny)(users|groups)\h+\H+')

    if [ -n "$config_output" ]; then
        l_output+="\n- SSHD configuration matching entries found:\n$config_output\n"
    else
        l_output+="\n- No relevant allow/deny configurations found in SSHD settings.\n"
    fi
}

# Function to check Match block configurations
CHECK_MATCH_BLOCK() {
    local match_user="sshuser"  # Change this to the desired user for the match test
    local match_output
    match_output=$(sshd -T -C user=$match_user 2>/dev/null | grep -Pi -- '^\h*(allow|deny)(users|groups)\h+\H+')

    if [ -n "$match_output" ]; then
        l_output+="\n- Additional check for Match block for user: $match_user\n"
        l_output+="\n- Configurations in Match block found:\n$match_output\n"
    else
        l_output+="\n- No relevant configurations found in Match block for user $match_user.\n"
    fi
}

# Perform the checks
CHECK_SSHD_CONFIG
CHECK_MATCH_BLOCK

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$l_output" | grep -q 'No relevant'; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally print the result to the console
echo -e "$RESULT"