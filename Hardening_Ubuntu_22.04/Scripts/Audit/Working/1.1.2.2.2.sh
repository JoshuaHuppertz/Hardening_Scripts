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

# Überprüfen, ob die nodev-Option gesetzt ist
echo "Überprüfe, ob die nodev-Option für /dev/shm gesetzt ist..."
NODEV_CHECK=$(findmnt -kn /dev/shm | grep -v nodev)

if [ -z "$NODEV_CHECK" ]; then
    check_command "Die nodev-Option ist für /dev/shm gesetzt."
else
    echo "FAIL: Die nodev-Option ist nicht für /dev/shm gesetzt."
fi
