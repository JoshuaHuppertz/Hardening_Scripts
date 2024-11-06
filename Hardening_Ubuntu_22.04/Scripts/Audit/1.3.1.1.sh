#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.3.1.1"

# Initialize output variable
l_output=""
l_apparmor_check=""
l_apparmor_utils_check=""

# Check if AppArmor is installed
l_apparmor_check=$(dpkg-query -s apparmor &>/dev/null && echo "apparmor is installed" || echo "apparmor is not installed")

# Check if apparmor-utils is installed
l_apparmor_utils_check=$(dpkg-query -s apparmor-utils &>/dev/null && echo "apparmor-utils is installed" || echo "apparmor-utils is not installed")

# Check if both apparmor and apparmor-utils are installed
if [[ "$l_apparmor_check" == *"not installed"* ]] || [[ "$l_apparmor_utils_check" == *"not installed"* ]]; then
    # Remediation step if either apparmor or apparmor-utils is missing
    l_output+="\n- ** FAIL **\n- AppArmor or apparmor-utils is not installed.\n"
    l_output+="- Remediating by installing apparmor and apparmor-utils...\n"
    # Install apparmor and apparmor-utils
    apt update -y && apt install -y apparmor apparmor-utils
    # Verify installation after remediation
    l_apparmor_check=$(dpkg-query -s apparmor &>/dev/null && echo "apparmor is installed" || echo "apparmor is not installed")
    l_apparmor_utils_check=$(dpkg-query -s apparmor-utils &>/dev/null && echo "apparmor-utils is installed" || echo "apparmor-utils is not installed")
    if [[ "$l_apparmor_check" == *"installed"* ]] && [[ "$l_apparmor_utils_check" == *"installed"* ]]; then
        l_output+="- AppArmor and apparmor-utils have been successfully installed.\n"
    else
        l_output+="- Failed to install AppArmor and/or apparmor-utils.\n"
    fi
else
    l_output+="\n- ** PASS **\n- AppArmor and apparmor-utils are already installed.\n"
fi

# Prepare result report
if [[ "$l_output" == *"FAIL"* ]]; then
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
