#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.3.2"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Flag zur Verfolgung von Fehlern
FAIL_FLAG=0

# Ergebnisse initialisieren
RESULTS="Audit: $AUDIT_NAME\n"

# Funktion zum Überprüfen, ob /home gemountet ist
check_home_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /home)

    if [[ $MOUNT_OUTPUT == *"/home"* ]]; then
        RESULTS+="\n/home: PASS\n\n -- INFO --\n/home ist gemountet\n"
    else
        RESULTS+="\n/home: FAIL\n\n -- INFO --\n/home ist nicht gemountet\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Funktion zum Überprüfen, ob die nodev-Option gesetzt ist
check_nodev_option() {
    NODEV_CHECK=$(findmnt -kn /home | grep -v nodev)

    if [ -z "$NODEV_CHECK" ]; then
        RESULTS+="\nnodv-Option: PASS\n\n -- INFO --\nDie nodev-Option ist für /home gesetzt\n"
    else
        RESULTS+="\nnodev-Option: FAIL\n\n -- INFO --\nDie nodev-Option ist nicht für /home gesetzt\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Starte die Überprüfungen
check_home_mount
check_nodev_option

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
