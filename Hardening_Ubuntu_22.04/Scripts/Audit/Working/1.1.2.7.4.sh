#!/bin/bash

# Funktion zum Überprüfen der Befehlsausführung
check_command() {
    if [ $? -eq 0 ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

# Überprüfen, ob /var/log/audit gemountet ist
echo "Überprüfe, ob /var/log/audit gemountet ist..."
MOUNT_OUTPUT=$(findmnt -kn /var/log/audit)
echo "$MOUNT_OUTPUT"

if [[ $MOUNT_OUTPUT == *"/var/log/audit"* ]]; then
    check_command "Findmnt zeigt, dass /var/log/audit gemountet ist."
else
    echo "FAIL: /var/log/audit ist nicht gemountet."
    exit 1
fi

# Überprüfen, ob die noexec-Option gesetzt ist
echo "Überprüfe, ob die noexec-Option für /var/log/audit gesetzt ist..."
NOEXEC_CHECK=$(findmnt -kn /var/log/audit | grep -v noexec)

if [ -z "$NOEXEC_CHECK" ]; then
    check_command "Die noexec-Option ist für /var/log/audit gesetzt."
else
    echo "FAIL: Die noexec-Option ist nicht für /var/log/audit gesetzt."
fi
