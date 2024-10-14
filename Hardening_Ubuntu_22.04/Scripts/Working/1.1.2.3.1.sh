#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.3.1"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zum Überprüfen, ob /home gemountet ist
check_home_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /home)

    if [[ $MOUNT_OUTPUT == *"/home"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/home: PASS\n\n -- INFO --\n/home ist gemountet\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/home: FAIL\n\n -- INFO --\n/home ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfung
check_home_mount
