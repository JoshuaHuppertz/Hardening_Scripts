#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.1"

# Initialize result variables
l_output=""
l_output2=""

# Check the on-disk rules in /etc/audit/rules.d/*.rules
l_disk_rules_output=$(awk '/^ *-w/ && /\/etc\/sudoers/ && / +-p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules)

# Define the expected on-disk rules
expected_disk_rules="-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d -p wa -k scope"

# Compare the actual disk rules with the expected ones
if [ "$l_disk_rules_output" == "$expected_disk_rules" ]; then
    l_output+="\n- On-disk rules are correctly configured:\n$l_disk_rules_output"
else
    l_output2+="\n- On-disk rules are not correctly configured:\n$l_disk_rules_output"
fi

# Check the running audit rules using auditctl
l_running_rules_output=$(auditctl -l | awk '/^ *-w/ && /\/etc\/sudoers/ && / +-p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)')

# Compare the actual running rules with the expected ones
if [ "$l_running_rules_output" == "$expected_disk_rules" ]; then
    l_output+="\n- Running rules are correctly configured:\n$l_running_rules_output"
else
    l_output2+="\n- Running rules are not correctly configured:\n$l_running_rules_output"
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
