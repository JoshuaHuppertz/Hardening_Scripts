#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.2.2"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob max_log_file_action in auditd.conf korrekt gesetzt ist
l_log_file_action_output=$(grep -P '^\s*max_log_file_action\s*=\s*keep_logs' /etc/audit/auditd.conf)

if [ -n "$l_log_file_action_output" ]; then
    l_output+="\n - Der Parameter 'max_log_file_action' ist korrekt gesetzt: $l_log_file_action_output."
else
    l_output2+="\n - Der Parameter 'max_log_file_action' ist nicht gesetzt oder falsch konfiguriert."
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Erfolgreich konfiguriert:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
