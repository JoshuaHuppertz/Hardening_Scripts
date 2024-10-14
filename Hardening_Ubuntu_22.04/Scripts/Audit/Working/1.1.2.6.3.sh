#!/bin/bash

# Funktion zum Überprüfen der Befehlsausführung
check_command() {
    if [ $? -eq 0 ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

# Überprüfen, ob /var/log gemountet ist
echo "Überprüfe, ob /var/log gemountet ist..."
MOUNT_OUTPUT=$(findmnt -kn /var/log)
echo "$MOUNT_OUTPUT"

if [[ $MOUNT_OUTPUT == *"/var/log"* ]]; then
    check_command "Findmnt zeigt, dass /var/log gemountet ist."
else
    echo "FAIL: /var/log ist nicht gemountet."
    exit 1
fi

# Überprüfen, ob die nosuid-Option gesetzt ist
echo "Überprüfe, ob die nosuid-Option für /var/log gesetzt ist..."
NOSUID_CHECK=$(findmnt -kn /var/log | grep -v nosuid)

if [ -z "$NOSUID_CHECK" ]; then
    check_command "Die nosuid-Option ist für /var/log gesetzt."
else
    echo "FAIL: Die nosuid-Option ist nicht für /var/log gesetzt."
fi
