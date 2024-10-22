#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.4.2"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Flag zur Verfolgung von Fehlern
FAIL_FLAG=0

# Ergebnisse initialisieren
RESULTS="Audit: $AUDIT_NAME\n"

# Funktion zur Überprüfung, ob /var gemountet ist
check_var_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /var)

    if [[ $MOUNT_OUTPUT == *"/var"* ]]; then
        RESULTS+="\n/var: PASS\n\n -- INFO --\n/var ist gemountet\n"
    else
        RESULTS+="\n/var: FAIL\n\n -- INFO --\n/var ist nicht gemountet\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Funktion zur Überprüfung, ob die nodev-Option gesetzt ist
check_nodev_option() {
    NODEV_CHECK=$(findmnt -kn /var | grep -v nodev)

    if [ -z "$NODEV_CHECK" ]; then
        RESULTS+="Die nodev-Option ist für /var gesetzt: PASS\n"
    else
        RESULTS+="Die nodev-Option ist nicht für /var gesetzt: FAIL\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Starte die Überprüfungen
check_var_mount
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
