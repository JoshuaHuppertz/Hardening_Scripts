#!/usr/bin/env bash

# Set the results directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.4.4"

# Initialize result variables
l_output=""
l_output2=""

# Permission mask
l_perm_mask="0027"

# Check if the auditd.conf file exists
if [ -e "/etc/audit/auditd.conf" ]; then
    # Read the log directory from the configuration file
    l_audit_log_directory="$(dirname "$(awk -F= '/^\s*log_file\s*/{print $2}' /etc/audit/auditd.conf | xargs)")"

    # Check if the directory exists
    if [ -d "$l_audit_log_directory" ]; then
        l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )) )"
        l_directory_mode="$(stat -Lc '%#a' "$l_audit_log_directory")"

        # Check if the permissions are restrictive enough
        if [ $(( $l_directory_mode & $l_perm_mask )) -gt 0 ]; then
            l_output2+="\n- ** FAIL **\n - Directory: \"$l_audit_log_directory\" has permission: \"$l_directory_mode\"\n (should be at least \"$l_maxperm\" or more restrictive)\n"
        else
            l_output+="\n- Directory: \"$l_audit_log_directory\" has the correct permissions: \"$l_directory_mode\"\n (should be at least \"$l_maxperm\" or more restrictive)\n"
        fi
    else
        l_output2+="\n- ** FAIL **\n- Log directory is not set in \"/etc/audit/auditd.conf\". Please specify a directory."
    fi
else
    l_output2+="\n- ** FAIL **\n- File: \"/etc/audit/auditd.conf\" not found.\n- ** Check if auditd is installed **"
fi

# Check the result and output it
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally, output the result to the console
#echo -e "$RESULT"
