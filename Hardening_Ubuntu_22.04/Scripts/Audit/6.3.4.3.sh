#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.4.3"

# Initialize result variables
l_output=""
l_output2=""

# Check if the auditd.conf file exists
if [ -e "/etc/audit/auditd.conf" ]; then
    # Check if the log_group parameter is set to adm or root
    log_group_output=$(grep -Piws -- '^\h*log_group\h*=\h*\H+\b' /etc/audit/auditd.conf | grep -Pvi -- '(adm)')
    
    # Check if the command produces any output
    if [ -n "$log_group_output" ]; then
        l_output2+="\n- ** FAIL **\n - The log_group parameter is not correctly set.\n"
    fi

    # Read the log directory from the configuration file
    l_fpath="$(dirname "$(awk -F "=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf | xargs)")"
    
    # Check if the directory exists
    if [ -d "$l_fpath" ]; then
        # Find files that are not owned by group "root" or "adm"
        while IFS= read -r -d $'\0' l_file; do
            l_output2+="\n - File: \"$l_file\" is not owned by group \"root\" or \"adm\"\n"
        done < <(find -L "$l_fpath" -not -path "$l_fpath"/lost+found -type f \( ! -group root -a ! -group adm \) -print0 2>/dev/null)
        
        # Check if no files were found
        if [ -z "$l_output2" ]; then
            l_output+="\n- All files in the directory \"$l_fpath\" are owned by group \"root\" or \"adm\"\n"
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
echo -e "$RESULT"
