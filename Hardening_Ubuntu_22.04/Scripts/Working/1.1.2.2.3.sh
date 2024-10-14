#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.2.3"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Funktion zum Überprüfen, ob /dev/shm gemountet ist
check_dev_shm_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /dev/shm)

    if [[ $MOUNT_OUTPUT == *"/dev/shm tmpfs"* ]]; then
        echo -e "Audit: $AUDIT_NAME\n/dev/shm: PASS\n\n -- INFO --\n/dev/shm ist gemountet als tmpfs\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\n/dev/shm: FAIL\n\n -- INFO --\n/dev/shm ist nicht gemountet\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Funktion zum Überprüfen, ob die nosuid-Option für /dev/shm gesetzt ist
check_nosuid_option() {
    NOSUID_CHECK=$(findmnt -kn /dev/shm | grep -v nosuid)

    if [ -z "$NOSUID_CHECK" ]; then
        echo -e "Audit: $AUDIT_NAME\nnosuid-Option: PASS\n\n -- INFO --\nDie nosuid-Option ist für /dev/shm gesetzt\n$SEPARATOR" >> "$RESULT_DIR/pass.txt"
    else
        echo -e "Audit: $AUDIT_NAME\nnosuid-Option: FAIL\n\n -- INFO --\nDie nosuid-Option ist nicht für /dev/shm gesetzt\n$SEPARATOR" >> "$RESULT_DIR/fail.txt"
        #exit 1  # Beende das Skript sofort, wenn ein Fail auftritt
    fi
}

# Starte die Überprüfungen
check_dev_shm_mount
check_nosuid_option
