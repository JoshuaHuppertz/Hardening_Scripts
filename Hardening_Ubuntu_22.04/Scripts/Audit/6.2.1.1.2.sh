#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.1.2"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob eine Override-Datei existiert
override_file="/etc/tmpfiles.d/systemd.conf"
default_file="/usr/lib/tmpfiles.d/systemd.conf"

if [ -f "$override_file" ]; then
    l_output="Override-Datei gefunden: $override_file. Diese Datei überschreibt die Standardwerte."
    inspected_file="$override_file"
else
    l_output="Keine Override-Datei gefunden. Verwende die Standarddatei: $default_file."
    inspected_file="$default_file"
fi

# Überprüfen der Dateiberechtigungen
permissions=$(stat -c "%a" "$inspected_file")
if [[ "$permissions" -ge 640 ]]; then
    l_output="$l_output\nDateiberechtigungen für \"$inspected_file\": $permissions - Berechtigungen sind korrekt."
else
    l_output2="$l_output2\nDateiberechtigungen für \"$inspected_file\": $permissions - Berechtigungen sind nicht ausreichend restriktiv."
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - * Korrekt konfiguriert * :$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n - * Korrekt konfiguriert * :\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
