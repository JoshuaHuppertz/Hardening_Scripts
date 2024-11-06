#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.4.1"
USERNAME="<username>"  # Replace <username> with the expected superuser name

# Initialize output variables
l_output=""
l_superuser_check=""
l_password_check=""

# Check for superuser setting
superuser_output=$(grep "^set superusers" /boot/grub/grub.cfg)
if [[ "$superuser_output" == "set superusers=\"$USERNAME\"" ]]; then
    l_superuser_check="** PASS **: Superuser is set to '$USERNAME'."
else
    l_superuser_check="** FAIL **: Superuser setting does not match expected username."
fi

# Check for password hash
password_output=$(awk -F. '/^\s*password/ {print $1"."$2"."$3}' /boot/grub/grub.cfg)
if [[ "$password_output" == "password_pbkdf2 $USERNAME grub.pbkdf2.sha512"* ]]; then
    l_password_check="** PASS **: Password is correctly set for '$USERNAME'."
else
    l_password_check="** FAIL **: Password setting does not match expected hash."
fi

# Compile output
l_output+="\n- Audit: $AUDIT_NUMBER\n"
l_output+="\n- Result:\n"
l_output+=" - $l_superuser_check\n"
l_output+=" - $l_password_check\n"

# Determine overall result
if [[ "$l_superuser_check" == *"FAIL"* ]] || [[ "$l_password_check" == *"FAIL"* ]]; then
    RESULT="\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit Result:\n ** PASS **\n$l_output\n"
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
