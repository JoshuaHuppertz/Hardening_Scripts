#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.1.1"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob auditd installiert ist
if dpkg-query -s auditd &>/dev/null; then
    l_output+="\n - auditd ist installiert."
else
    l_output2+="\n - auditd ist nicht installiert."
fi

# Überprüfen, ob audispd-plugins installiert ist
if dpkg-query -s audispd-plugins &>/dev/null; then
    l_output+="\n - audispd-plugins sind installiert."
else
    l_output2+="\n - audispd-plugins sind nicht installiert."
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
