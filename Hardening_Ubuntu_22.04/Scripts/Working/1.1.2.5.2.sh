#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.5.2"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zur Überprüfung, ob /var/tmp gemountet ist
check_var_tmp_mount() {
    echo "Überprüfe, ob /var/tmp gemountet ist..."
    MOUNT_OUTPUT=$(findmnt -kn /var/tmp)
    echo "$MOUNT_OUTPUT"

    if [[ $MOUNT_OUTPUT == *"/var/tmp"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/var/tmp: PASS\n\n -- INFO --\n/var/tmp ist gemountet\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/var/tmp: FAIL\n\n -- INFO --\n/var/tmp ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zur Überprüfung, ob die nodev-Option gesetzt ist
check_nodev_option() {
    echo "Überprüfe, ob die nodev-Option für /var/tmp gesetzt ist..."
    NODEV_CHECK=$(findmnt -kn /var/tmp | grep -v nodev)

    if [ -z "$NODEV_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nDie nodev-Option ist für /var/tmp gesetzt: PASS\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nDie nodev-Option ist nicht für /var/tmp gesetzt: FAIL\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_var_tmp_mount
check_nodev_option
