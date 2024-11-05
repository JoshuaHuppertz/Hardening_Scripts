#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.3"

# Initialize output variables
l_output=""
l_output2=""
l_pkgoutput=""
l_gdmfile=""
l_gdmprofile=""

# Check for GDM and GDM3 packages
l_pcl="gdm gdm3" # Space separated list of packages to check
for l_pn in $l_pcl; do
    if dpkg-query -s "$l_pn" &> /dev/null; then
        l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
    fi
done

if [ -n "$l_pkgoutput" ]; then
    echo -e "$l_pkgoutput" >> "$RESULT_DIR/output.log"
    
    # Look for the disable-user-list setting
    l_gdmfile="$(grep -Pril '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db)"
    
    if [ -n "$l_gdmfile" ]; then
        l_output="$l_output\n - The \"disable-user-list\" option is enabled in \"$l_gdmfile\""
        
        # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
        l_gdmprofile="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<< "$l_gdmfile")"
        
        if grep -Pq "^\h*system-db:$l_gdmprofile" /etc/dconf/profile/"$l_gdmprofile"; then
            l_output="$l_output\n - The \"$l_gdmprofile\" profile exists"
        else
            l_output2="$l_output2\n - The \"$l_gdmprofile\" doesn't exist"
        fi

        if [ -f "/etc/dconf/db/$l_gdmprofile" ]; then
            l_output="$l_output\n - The \"$l_gdmprofile\" profile exists in the dconf database"
        else
            l_output2="$l_output2\n - The \"$l_gdmprofile\" profile doesn't exist in the dconf database"
        fi
    else
        l_output2="$l_output2\n - The \"disable-user-list\" option is not enabled"
    fi
else
    echo -e "\n - GNOME Desktop Manager isn't installed\n - Recommendation is Not Applicable\n- Audit result:\n *** PASS ***\n" >> "$RESULT_DIR/output.log"
    exit 0
fi

# Prepare result report
if [ -z "$l_output2" ]; then
    # PASS: No issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    # FAIL: Issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT="$RESULT\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
