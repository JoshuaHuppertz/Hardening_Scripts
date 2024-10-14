#!/usr/bin/env bash

# Audit-Name
AUDIT_NAME="1.1.2.7.4"

# Initialisiere Ergebnisverzeichnis
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Stelle sicher, dass das Verzeichnis existiert

# Trennlinie
SEPARATOR="-------------------------------------------------"

# Flag zur Verfolgung von Fehlern
FAIL_FLAG=0

# Ergebnisse initialisieren
RESULTS="Audit: $AUDIT_NAME\n"

# Funktion zur Überprüfung, ob /var/log/audit gemountet ist
check_var_log_audit_mount() {
    MOUNT_OUTPUT=$(findmnt -kn /var/log/audit)
    if [[ $MOUNT_OUTPUT == *"/var/log/audit"* ]]; then
        RESULTS+="\n/var/log/audit: PASS\n\n -- INFO --\n/var/log/audit ist gemountet\n"
    else
        RESULTS+="\n/var/log/audit: FAIL\n\n -- INFO --\n/var/log/audit ist nicht gemountet\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Funktion zur Überprüfung, ob die noexec-Option gesetzt ist
check_noexec_option() {
    NOEXEC_CHECK=$(findmnt -kn /var/log/audit | grep -v noexec)
    if [ -z "$NOEXEC_CHECK" ]; then
        RESULTS+="Die noexec-Option ist für /var/log/audit gesetzt: PASS\n"
    else
        RESULTS+="Die noexec-Option ist nicht für /var/log/audit gesetzt: FAIL\n"
        FAIL_FLAG=1  # Setze den Fehler-Flag
    fi
}

# Starte die Überprüfungen
check_var_log_audit_mount
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