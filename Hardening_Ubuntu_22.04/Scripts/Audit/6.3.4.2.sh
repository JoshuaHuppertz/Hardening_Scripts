#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.4.2"

# Initialize result variables
l_output=""
l_output2=""

# Check if the auditd.conf file exists
if [ -e "/etc/audit/auditd.conf" ]; then
    # Check if the log directory exists
    l_audit_log_directory="$(dirname "$(awk -F= '/^\s*log_file\s*/{print $2}' /etc/audit/auditd.conf | xargs)")"
    
    if [ -d "$l_audit_log_directory" ]; then
        # Find files that are not owned by the user "root"
        while IFS= read -r -d $'\0' l_file; do
            l_output2+="\n - File: \"$l_file\" is owned by user: \"$(stat -Lc '%U' "$l_file")\"\n (should be owned by user: \"root\")\n"
        done < <(find "$l_audit_log_directory" -maxdepth 1 -type f ! -user root -print0)
        
        # Check if no files were found
        if [ -z "$l_output2" ]; then
            l_output+="\n- All files in the directory \"$l_audit_log_directory\" are owned by user: \"root\"\n"
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
