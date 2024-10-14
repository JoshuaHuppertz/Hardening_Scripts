#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.2.4"

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

# Funktion zum Überprüfen, ob die noexec-Option für /dev/shm gesetzt ist
check_noexec_option() {
    NOEXEC_CHECK=$(findmnt -kn /dev/shm | grep -v noexec)

    if [ -z "$NOEXEC_CHECK" ]; then
        RESULTS+="noexec-Option: PASS\n\n -- INFO --\nDie noexec-Option ist für /dev/shm gesetzt\n"
    else
        RESULTS+="noexec-Option: FAIL\n\n -- INFO --\nDie noexec-Option ist nicht für /dev/shm gesetzt\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Starte die Überprüfungen
check_dev_shm_mount
check_noexec_option

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
