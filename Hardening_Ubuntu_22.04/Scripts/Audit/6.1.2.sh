#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.1.2"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Funktion zur Überprüfung der Cron-Job-Konfiguration
check_cron_job() {
    # Überprüfen, ob ein Cron-Job für aide vorhanden ist
    if grep -Prs '^([^#\n\r]+\h+)?(\/usr\/s?bin\/|^\h*)aide(\.wrapper)?\h+(--(check|update)|([^#\n\r]+\h+)?\$AIDEARGS)\b' /etc/cron.* /etc/crontab /var/spool/cron/; then
        l_output+="\n - Ein gültiger Cron-Job für aide wurde gefunden."
    else
        l_output2+="\n - Kein gültiger Cron-Job für aide gefunden."
    fi
}

# Funktion zur Überprüfung des aidecheck.services und aidecheck.timer
check_aidecheck_service() {
    # Überprüfen, ob aidecheck.service aktiviert ist
    if systemctl is-enabled aidecheck.service &>/dev/null; then
        l_output+="\n - aidecheck.service ist aktiviert."
    else
        l_output2+="\n - aidecheck.service ist nicht aktiviert."
    fi

    # Überprüfen, ob aidecheck.timer aktiviert ist
    if systemctl is-enabled aidecheck.timer &>/dev/null; then
        l_output+="\n - aidecheck.timer ist aktiviert."
    else
        l_output2+="\n - aidecheck.timer ist nicht aktiviert."
    fi

    # Überprüfen, ob aidecheck.timer läuft
    if systemctl is-active aidecheck.timer &>/dev/null; then
        l_output+="\n - aidecheck.timer läuft."
    else
        l_output2+="\n - aidecheck.timer läuft nicht."
    fi
}

# Audit durchführen
check_cron_job
check_aidecheck_service

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - * Korrekt konfiguriert *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- * Korrekt konfiguriert *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
