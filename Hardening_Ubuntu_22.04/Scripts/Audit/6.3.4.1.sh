#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.4.1"

# Initialize result variables
l_output=""
l_output2=""

# Permission masks
l_perm_mask="0137"

# Check if the auditd.conf file exists
if [ -e "/etc/audit/auditd.conf" ]; then
    # Read the log directory from the configuration file
    l_audit_log_directory="$(dirname "$(awk -F= '/^\s*log_file\s*/{print $2}' /etc/audit/auditd.conf | xargs)")"

    # Check if the directory exists
    if [ -d "$l_audit_log_directory" ]; then
        l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )) )"
        a_files=()

        # Find files in the audit log directory with the specified permissions
        while IFS= read -r -d $'\0' l_file; do
            [ -e "$l_file" ] && a_files+=("$l_file")
        done < <(find "$l_audit_log_directory" -maxdepth 1 -type f -perm /"$l_perm_mask" -print0)

        # Check if any files were found
        if (( "${#a_files[@]}" > 0 )); then
            for l_file in "${a_files[@]}"; do
                l_file_mode="$(stat -Lc '%#a' "$l_file")"
                l_output2+="\n- ** FAIL **\n- File: \"$l_file\" has permission: \"$l_file_mode\"\n (should be at least \"$l_maxperm\" or more restrictive)\n"
            done
        else
            l_output+="\n- All files in \"$l_audit_log_directory\" have the required permissions: \"$l_maxperm\" or more restrictive"
        fi
    else
        l_output2+="\n- ** FAIL **\n- The log directory is not specified in \"/etc/audit/auditd.conf\". Please specify the directory."
    fi
else
    l_output2+="\n- ** FAIL **\n- File: \"/etc/audit/auditd.conf\" not found.\n- ** Please check if auditd is installed **"
fi

# Check and output the result
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

# Optional: Output the result to the console
#echo -e "$RESULT"
