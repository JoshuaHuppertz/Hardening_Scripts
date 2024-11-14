#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.2"

# Initialize result variables
l_output=""
l_output2=""

# Check on-disk rules
l_disk_rules_output=$(sudo awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F *auid!=unset/ || / -F *auid!=-1/ || / -F *auid!=4294967295/) \
&&(/ -C *euid!=uid/ || / -C *uid!=euid/) \
&&/ -S *execve/ \
&&(/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null)

# Define the expected on-disk rules
expected_disk_rules="-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation
-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation"

# Compare the actual disk rules with the expected ones
if [ "$l_disk_rules_output" == "$expected_disk_rules" ]; then
    l_output+="\n- On-disk rules are correctly configured:\n$l_disk_rules_output"
else
    l_output2+="\n- On-disk rules are not correctly configured:\n$l_disk_rules_output"
    l_output2+="\n- Expected on-disk rules:\n$expected_disk_rules\n"
fi

# Check running rules
l_running_rules_output=$(sudo auditctl -l | awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F *auid!=unset/ || / -F *auid!=-1/ || / -F *auid!=4294967295/) \
&&(/ -C *euid!=uid/ || / -C *uid!=euid/) \
&&/ -S *execve/ \
&&(/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' 2>/dev/null)

# Define the expected running rules
expected_running_rules="-a always,exit -F arch=b64 -S execve -C uid!=euid -F auid!=-1 -F key=user_emulation
-a always,exit -F arch=b32 -S execve -C uid!=euid -F auid!=-1 -F key=user_emulation"

# Compare the actual running rules with the expected ones
if [ "$l_running_rules_output" == "$expected_running_rules" ]; then
    l_output+="\n- Running rules are correctly configured:\n$l_running_rules_output"
else
    l_output2+="\n- Running rules are not correctly configured:\n$l_running_rules_output"
    l_output2+="\n- Expected running rules:\n$l_running_rules_output"
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
