#!/bin/bash

# Funktion zum Überprüfen der Befehlsausführung
check_command() {
    if [ $? -eq 0 ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

# Überprüfen, ob /dev/shm gemountet ist
echo "Überprüfe, ob /dev/shm gemountet ist..."
MOUNT_OUTPUT=$(findmnt -kn /dev/shm)
echo "$MOUNT_OUTPUT"

if [[ $MOUNT_OUTPUT == *"/dev/shm tmpfs"* ]]; then
    check_command "Findmnt zeigt, dass /dev/shm gemountet ist."
else
    echo "FAIL: /dev/shm ist nicht gemountet."
    exit 1
fi
