#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.1.1"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zum Überprüfen des Mount-Status von /tmp
check_tmp_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /tmp)
    
    if [[ $MOUNT_OUTPUT == *"/tmp tmpfs"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/tmp: PASS\n\n -- INFO --\n/tmp ist gemountet als tmpfs\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/tmp: FAIL\n\n -- INFO --\n/tmp ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zum Überprüfen des systemd-Status für tmp.mount
check_systemd_tmp_mount() {
    SYSTEMD_STATUS=$(systemctl is-enabled tmp.mount)
    
    if [[ $SYSTEMD_STATUS == "generated" || $SYSTEMD_STATUS == "enabled" ]]; then
        echo -e "Audit: $AUDIT_NAME\ntmp.mount: PASS\n\n -- INFO --\nsystemd aktiviert tmp.mount beim Booten\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\ntmp.mount: FAIL\n\n -- INFO --\ntmp.mount ist entweder maskiert oder deaktiviert\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_tmp_mount
check_systemd_tmp_mount
