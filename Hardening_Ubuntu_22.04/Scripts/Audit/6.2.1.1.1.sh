#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.1.1"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob systemd-journald aktiviert ist
enabled_status=$(systemctl is-enabled systemd-journald.service 2>/dev/null)
if [[ "$enabled_status" == "static" ]]; then
    l_output="systemd-journald ist aktiviert: $enabled_status"
else
    l_output2="systemd-journald ist nicht statisch oder aktiviert: $enabled_status"
fi

# Überprüfen, ob systemd-journald aktiv ist
active_status=$(systemctl is-active systemd-journald.service 2>/dev/null)
if [[ "$active_status" == "active" ]]; then
    l_output="$l_output\nsystemd-journald ist aktiv: $active_status"
else
    l_output2="$l_output2\nsystemd-journald ist nicht aktiv: $active_status"
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
