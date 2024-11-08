#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.14"

# Initialize output variables
output_samba_installed=""
output_enabled=""
output_active=""

# Check if samba is installed
if dpkg-query -s samba &>/dev/null; then
    output_samba_installed="samba is installed"
fi

# If the package is installed, check its service status
if [[ -n "$output_samba_installed" ]]; then
    # Check if smbd.service is enabled
    if systemctl is-enabled smbd.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="smbd.service is enabled"
    fi

    # Check if smbd.service is active
    if systemctl is-active smbd.service 2>/dev/null | grep -q '^active'; then
        output_active="smbd.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_samba_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- samba is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_samba_installed" ]]; then
        RESULT+="- Reason: $output_samba_installed\n"
    fi
    if [[ -n "$output_enabled" ]]; then
        RESULT+="- Reason: $output_enabled\n"
    fi
    if [[ -n "$output_active" ]]; then
        RESULT+="- Reason: $output_active\n"
    fi
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
