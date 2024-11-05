#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.2.1"

# Initialize output variables
l_output=""
l_output2=""

# Check iptables policies
input_policy=$(iptables -L INPUT -n | awk '/Chain INPUT/{getline; print $3}')
forward_policy=$(iptables -L FORWARD -n | awk '/Chain FORWARD/{getline; print $3}')
output_policy=$(iptables -L OUTPUT -n | awk '/Chain OUTPUT/{getline; print $3}')

# Check INPUT policy
if [[ "$input_policy" == "DROP" || "$input_policy" == "REJECT" ]]; then
    l_output+="\n - INPUT chain policy is set to: $input_policy"
else
    l_output2+="\n - INPUT chain policy is not set to DROP or REJECT, it is: $input_policy"
fi

# Check FORWARD policy
if [[ "$forward_policy" == "DROP" || "$forward_policy" == "REJECT" ]]; then
    l_output+="\n - FORWARD chain policy is set to: $forward_policy"
else
    l_output2+="\n - FORWARD chain policy is not set to DROP or REJECT, it is: $forward_policy"
fi

# Check OUTPUT policy
if [[ "$output_policy" == "DROP" || "$output_policy" == "REJECT" ]]; then
    l_output+="\n - OUTPUT chain policy is set to: $output_policy"
else
    l_output2+="\n - OUTPUT chain policy is not set to DROP or REJECT, it is: $output_policy"
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally print the result to the console
echo -e "$RESULT"
