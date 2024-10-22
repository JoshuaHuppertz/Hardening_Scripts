#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.1.1"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Flag zur Verfolgung von Fehlern
FAIL_FLAG=0

# Ergebnisse initialisieren
RESULTS="Audit: $AUDIT_NAME\n"

# Funktion zum Überprüfen des Mount-Status von /tmp
check_tmp_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /tmp)
    
    if [[ $MOUNT_OUTPUT == *"/tmp tmpfs"* ]]; then
        RESULTS+="\n/tmp: PASS\n\n -- INFO --\n/tmp ist gemountet als tmpfs\n"
    else
        RESULTS+="\n/tmp: FAIL\n\n -- INFO --\n/tmp ist nicht gemountet\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Funktion zum Überprüfen des systemd-Status für tmp.mount
check_systemd_tmp_mount() {
    SYSTEMD_STATUS=$(systemctl is-enabled tmp.mount)
    
    if [[ $SYSTEMD_STATUS == "generated" || $SYSTEMD_STATUS == "enabled" ]]; then
        RESULTS+="\ntmp.mount: PASS\n\n -- INFO --\nsystemd aktiviert tmp.mount beim Booten\n"
    else
        RESULTS+="\ntmp.mount: FAIL\n\n -- INFO --\ntmp.mount ist entweder maskiert oder deaktiviert\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Starte die Überprüfungen
check_tmp_mount
check_systemd_tmp_mount

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
