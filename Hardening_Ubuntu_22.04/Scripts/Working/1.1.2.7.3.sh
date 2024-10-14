#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.7.3"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zur Überprüfung, ob /var/log/audit gemountet ist
check_var_log_audit_mount() {
    echo "Überprüfe, ob /var/log/audit gemountet ist..."
    MOUNT_OUTPUT=$(findmnt -kn /var/log/audit)
    echo "$MOUNT_OUTPUT"

    if [[ $MOUNT_OUTPUT == *"/var/log/audit"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/var/log/audit: PASS\n\n -- INFO --\n/var/log/audit ist gemountet\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/var/log/audit: FAIL\n\n -- INFO --\n/var/log/audit ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zur Überprüfung, ob die nosuid-Option gesetzt ist
check_nosuid_option() {
    echo "Überprüfe, ob die nosuid-Option für /var/log/audit gesetzt ist..."
    NOSUID_CHECK=$(findmnt -kn /var/log/audit | grep -v nosuid)

    if [ -z "$NOSUID_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nDie nosuid-Option ist für /var/log/audit gesetzt: PASS\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nDie nosuid-Option ist nicht für /var/log/audit gesetzt: FAIL\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_var_log_audit_mount
check_nosuid_option
