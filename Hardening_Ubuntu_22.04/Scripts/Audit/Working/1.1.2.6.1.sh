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
