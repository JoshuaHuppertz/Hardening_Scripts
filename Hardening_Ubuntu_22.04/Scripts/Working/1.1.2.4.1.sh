#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.4.1"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zum Überprüfen, ob /var gemountet ist
check_var_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /var)

    if [[ $MOUNT_OUTPUT == *"/var"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/var: PASS\n\n -- INFO --\n/var ist gemountet\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/var: FAIL\n\n -- INFO --\n/var ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfung
check_var_mount
