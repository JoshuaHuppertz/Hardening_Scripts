#!/bin/bash

# Funktion zum Überprüfen der Befehlsausführung
check_command() {
    if [ $? -eq 0 ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

# Überprüfen, ob /var gemountet ist
echo "Überprüfe, ob /var gemountet ist..."
MOUNT_OUTPUT=$(findmnt -kn /var)
echo "$MOUNT_OUTPUT"

if [[ $MOUNT_OUTPUT == *"/var"* ]]; then
    check_command "Findmnt zeigt, dass /var gemountet ist."
else
    echo "FAIL: /var ist nicht gemountet."
    exit 1
fi

# Überprüfen, ob die nodev-Option gesetzt ist
echo "Überprüfe, ob die nodev-Option für /var gesetzt ist..."
NODEV_CHECK=$(findmnt -kn /var | grep -v nodev)

if [ -z "$NODEV_CHECK" ]; then
    check_command "Die nodev-Option ist für /var gesetzt."
else
    echo "FAIL: Die nodev-Option ist nicht für /var gesetzt."
fi
