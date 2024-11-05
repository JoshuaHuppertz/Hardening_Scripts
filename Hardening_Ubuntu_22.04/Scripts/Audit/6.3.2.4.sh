#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.2.4"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob space_left_action auf email, exec, single oder halt gesetzt ist
l_space_left_action_output=$(grep -Pi '^\s*space_left_action\s*=\s*(email|exec|single|halt)\b' /etc/audit/auditd.conf)

if [ -n "$l_space_left_action_output" ]; then
    l_output+="\n - Der Parameter 'space_left_action' ist korrekt gesetzt: $l_space_left_action_output."
else
    l_output2+="\n - Der Parameter 'space_left_action' ist nicht gesetzt oder falsch konfiguriert (er sollte auf email, exec, single oder halt gesetzt sein)."
fi

# Überprüfen, ob admin_space_left_action auf single oder halt gesetzt ist
l_admin_space_left_action_output=$(grep -Pi '^\s*admin_space_left_action\s*=\s*(single|halt)\b' /etc/audit/auditd.conf)

if [ -n "$l_admin_space_left_action_output" ]; then
    l_output+="\n - Der Parameter 'admin_space_left_action' ist korrekt gesetzt: $l_admin_space_left_action_output."
else
    l_output2+="\n - Der Parameter 'admin_space_left_action' ist nicht gesetzt oder falsch konfiguriert (er sollte auf single oder halt gesetzt sein)."
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
