#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.4.2"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zur Überprüfung, ob /var gemountet ist
check_var_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /var)

    if [[ $MOUNT_OUTPUT == *"/var"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/var: PASS\n\n -- INFO --\n/var ist gemountet\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/var: FAIL\n\n -- INFO --\n/var ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zur Überprüfung, ob die nodev-Option gesetzt ist
check_nodev_option() {
    NODEV_CHECK=$(findmnt -kn /var | grep -v nodev)

    if [ -z "$NODEV_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nDie nodev-Option ist für /var gesetzt: PASS\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nDie nodev-Option ist nicht für /var gesetzt: FAIL\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_var_mount
check_nodev_option
