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
fi

# Überprüfen, ob systemd die tmp.mount beim Booten aktivieren kann
echo "Überprüfe den Status von tmp.mount..."
SYSTEMD_STATUS=$(systemctl is-enabled tmp.mount)
echo "$SYSTEMD_STATUS"

if [[ $SYSTEMD_STATUS == "generated" || $SYSTEMD_STATUS == "enabled" ]]; then
    check_command "systemd wird tmp.mount beim Booten aktivieren."
else
    echo "FAIL: tmp.mount ist entweder maskiert oder deaktiviert."
fi
