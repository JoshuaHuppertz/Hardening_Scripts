#!/bin/bash

# Funktion zum Überprüfen der Befehlsausführung
check_command() {
    if [ $? -eq 0 ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

# Überprüfen, ob /home gemountet ist
echo "Überprüfe, ob /home gemountet ist..."
MOUNT_OUTPUT=$(findmnt -kn /home)
echo "$MOUNT_OUTPUT"

if [[ $MOUNT_OUTPUT == *"/home"* ]]; then
    check_command "Findmnt zeigt, dass /home gemountet ist."
else
    echo "FAIL: /home ist nicht gemountet."
    exit 1
fi
