#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.2.2"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen der Konfiguration für systemd-journal-upload
l_config_file="/etc/systemd/journal-upload.conf"

# Überprüfen, ob die Konfigurationsdatei existiert
if [ -f "$l_config_file" ]; then
    l_check_output=$(grep -P "^ *URL=|^ *ServerKeyFile=|^ *ServerCertificateFile=|^ *TrustedCertificateFile=" "$l_config_file")
    
    if [ -n "$l_check_output" ]; then
        l_output="Authentication configuration is present:\n$l_check_output"
    else
        l_output2="No authentication configuration found in $l_config_file."
    fi
else
    l_output2="Configuration file $l_config_file not found."
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
