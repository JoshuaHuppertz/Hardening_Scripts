#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.1.4"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob audit_backlog_limit= in grub.cfg vorhanden ist
l_backlog_output=$(find /boot -type f -name 'grub.cfg' -exec grep -Ph -- '^\h*linux' {} + | grep -Pv 'audit_backlog_limit=\d+\b')

if [ -z "$l_backlog_output" ]; then
    l_output+="\n - Der Parameter 'audit_backlog_limit=' ist gesetzt."
else
    l_output2+="\n - Der Parameter 'audit_backlog_limit=' ist nicht gesetzt."
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
