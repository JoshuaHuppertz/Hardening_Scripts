#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.2.1"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Flag zur Verfolgung von Fehlern
FAIL_FLAG=0

# Ergebnisse initialisieren
RESULTS="Audit: $AUDIT_NAME\n"

# Funktion zum Überprüfen, ob /dev/shm gemountet ist
check_dev_shm_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /dev/shm)

    if [[ $MOUNT_OUTPUT == *"/dev/shm tmpfs"* ]]; then
        RESULTS+="\n/dev/shm: PASS\n\n -- INFO --\n/dev/shm ist gemountet als tmpfs\n"
    else
        RESULTS+="\n/dev/shm: FAIL\n\n -- INFO --\n/dev/shm ist nicht gemountet\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Starte die Überprüfung
check_dev_shm_mount

# Ergebnisse speichern
if [[ $FAIL_FLAG -eq 1 ]]; then
    # Wenn Fehler aufgetreten sind, schreibe alles in die Fail-Datei
    echo -e "$RESULTS" >> "$RESULT_DIR/fail.txt"
else
    # Andernfalls schreibe alles in die Pass-Datei
    echo -e "$RESULTS" >> "$RESULT_DIR/pass.txt"
fi

# Füge die Trennlinie am Ende der Ergebnisse hinzu
echo -e "$SEPARATOR" >> "$RESULT_DIR/$(if [[ $FAIL_FLAG -eq 1 ]]; then echo 'fail'; else echo 'pass'; fi).txt"
