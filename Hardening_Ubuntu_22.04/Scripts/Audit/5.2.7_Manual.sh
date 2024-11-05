#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.7"

# Initialize output variables
l_output=""
group_name=""
group_check=""

# Function to check pam_wheel configuration
CHECK_PAM_WHEEL() {
    # Check for pam_wheel configuration in /etc/pam.d/su
    if output=$(grep -Pi '^\h*auth\h+(?:required|requisite)\h+pam_wheel\.so\h+(?:[^#\n\r]+\h+)?((?!\2)(use_uid\b|group=\H+\b))\h+(?:[^#\n\r]+\h+)?((?!\1)(use_uid\b|group=\H+\b))(h+.*)?$' /etc/pam.d/su); then
        if [ -n "$output" ]; then
            l_output+="\n - pam_wheel is configured correctly: $output"
            group_name=$(echo "$output" | grep -oP "group=\K\H+")
        else
            l_output+="\n - pam_wheel is NOT configured correctly in /etc/pam.d/su."
        fi
    fi
}

# Function to check the specified group for users
CHECK_GROUP_USERS() {
    if [ -n "$group_name" ]; then
        group_check=$(grep "$group_name" /etc/group)
        if [ -n "$group_check" ]; then
            if [[ "$group_check" == *":"* ]]; then
                user_count=$(echo "$group_check" | awk -F: '{print $4}' | tr ',' '\n' | wc -l)
                if [ "$user_count" -gt 0 ]; then
                    l_output+="\n - Group $group_name contains users: $group_check"
                else
                    l_output+="\n - Group $group_name is empty."
                fi
            fi
        else
            l_output+="\n - Group $group_name does not exist."
        fi
    fi
}

# Perform the checks
CHECK_PAM_WHEEL
CHECK_GROUP_USERS

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ $l_output == *"NOT configured correctly"* || $l_output == *"contains users"* ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - * Reasons for audit failure * :$l_output"
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
