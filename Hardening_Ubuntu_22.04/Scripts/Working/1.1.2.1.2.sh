#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.1.2"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zum Überprüfen, ob /tmp gemountet ist
check_tmp_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /tmp)

    if [[ $MOUNT_OUTPUT == *"/tmp tmpfs"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/tmp: PASS\n\n -- INFO --\n/tmp ist gemountet als tmpfs\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/tmp: FAIL\n\n -- INFO --\n/tmp ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zum Überprüfen, ob die nodev-Option für /tmp gesetzt ist
check_nodev_option() {
    NODEV_CHECK=$(findmnt -kn /tmp | grep -v nodev)

    if [ -z "$NODEV_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nnodev-Option: PASS\n\n -- INFO --\nDie nodev-Option ist für /tmp gesetzt\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nnodev-Option: FAIL\n\n -- INFO --\nDie nodev-Option ist nicht für /tmp gesetzt\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
