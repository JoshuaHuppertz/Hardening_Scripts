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

# Überprüfen, ob die nodev-Option gesetzt ist
echo "Überprüfe, ob die nodev-Option für /home gesetzt ist..."
NODEV_CHECK=$(findmnt -kn /home | grep -v nodev)

if [ -z "$NODEV_CHECK" ]; then
    check_command "Die nodev-Option ist für /home gesetzt."
else
    echo "FAIL: Die nodev-Option ist nicht für /home gesetzt."
fi
