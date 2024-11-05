#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.2.1"

# Ergebnisvariablen initialisieren
l_output=""

# Überprüfen der Benutzer auf Schattenpasswörter
l_check_output=$(awk -F: '($2 != "x") { print "User: \"" $1 "\" is not set to shadowed passwords" }' /etc/passwd)

# Überprüfen, ob Ausgaben von dem Befehl zurückgegeben werden
if [ -z "$l_check_output" ]; then
    l_output=" - Alle Benutzer sind korrekt auf Schattenpasswörter gesetzt."
else
    l_output=" - Folgende Benutzer sind nicht auf Schattenpasswörter gesetzt:\n$l_check_output"
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_check_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
