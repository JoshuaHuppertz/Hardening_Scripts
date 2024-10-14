#!/bin/bash

# Funktion zum Überprüfen der Befehlsausführung
check_command() {
    if [ $? -eq 0 ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

# Überprüfen, ob /tmp gemountet ist
echo "Überprüfe, ob /tmp gemountet ist..."
MOUNT_OUTPUT=$(findmnt -kn /tmp)
echo "$MOUNT_OUTPUT"

if [[ $MOUNT_OUTPUT == *"/tmp tmpfs"* ]]; then
    check_command "Findmnt zeigt, dass /tmp gemountet ist."
else
    echo "FAIL: /tmp ist nicht gemountet."
    exit 1
fi

# Überprüfen, ob die nosuid-Option gesetzt ist
echo "Überprüfe, ob die nosuid-Option für /tmp gesetzt ist..."
NOSUID_CHECK=$(findmnt -kn /tmp | grep -v nosuid)

if [ -z "$NOSUID_CHECK" ]; then
    check_command "Die nosuid-Option ist für /tmp gesetzt."
else
    echo "FAIL: Die nosuid-Option ist nicht für /tmp gesetzt."
fi
