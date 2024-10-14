#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.6.4"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zur Überprüfung, ob /var/log gemountet ist
check_var_log_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /var/log)
    if [[ $MOUNT_OUTPUT == *"/var/log"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/var/log: PASS\n\n -- INFO --\n/var/log ist gemountet\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/var/log: FAIL\n\n -- INFO --\n/var/log ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zur Überprüfung, ob die noexec-Option gesetzt ist
check_noexec_option() {
    NOEXEC_CHECK=$(findmnt -kn /var/log | grep -v noexec)
    if [ -z "$NOEXEC_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nDie noexec-Option ist für /var/log gesetzt: PASS\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nDie noexec-Option ist nicht für /var/log gesetzt: FAIL\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_var_log_mount
check_noexec_option
