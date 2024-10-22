#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="3.1.2"

# Initialize output variables
l_output=""
l_output2=""

# Function to check wireless module
module_chk() {
    local l_mname="$1"
    
    # Check how the module will be loaded
    l_loadable="$(modprobe -n -v "$l_mname")"
    if grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
        l_output="$l_output\n - Modul: \"$l_mname\" ist nicht ladbar: \"$l_loadable\""
    else
        l_output2="$l_output2\n - Modul: \"$l_mname\" ist ladbar: \"$l_loadable\""
    fi

    # Check if the module is currently loaded
    if ! lsmod | grep "$l_mname" > /dev/null 2>&1; then
        l_output="$l_output\n - Modul: \"$l_mname\" ist nicht geladen"
    else
        l_output2="$l_output2\n - Modul: \"$l_mname\" ist geladen"
    fi

    # Check if the module is deny listed
    if modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mname\b"; then
        l_output="$l_output\n - Modul: \"$l_mname\" steht auf der Blacklist in: \"$(grep -Pl -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*)\""
    else
        l_output2="$l_output2\n - Modul: \"$l_mname\" steht nicht auf der Blacklist"
    fi
}

# Check if wireless interfaces are present
if [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
    l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do
        basename "$(readlink -f "$driverdir"/device/driver/module)"
    done | sort -u)

    # Check each wireless module
    for l_mname in $l_dname; do
        module_chk "$l_mname"
    done
fi

# Prepare result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n - System hat keine drahtlosen NICs installiert\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n - Grund(e) für den Auditfehler:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Korrekt eingestellt:\n$l_output\n"
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
