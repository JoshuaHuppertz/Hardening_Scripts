#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.1.4"

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

# Funktion zum Überprüfen, ob die noexec-Option für /tmp gesetzt ist
check_noexec_option() {
    NOEXEC_CHECK=$(findmnt -kn /tmp | grep -v noexec)

    if [ -z "$NOEXEC_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nnoexec-Option: PASS\n\n -- INFO --\nDie noexec-Option ist für /tmp gesetzt\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nnoexec-Option: FAIL\n\n -- INFO --\nDie noexec-Option ist nicht für /tmp gesetzt\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_tmp_mount
check_noexec_option
