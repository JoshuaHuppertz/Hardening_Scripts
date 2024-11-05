#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.2.4"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob systemd-journal-remote.socket und systemd-journal-remote.service nicht aktiviert sind
l_enabled_output=$(systemctl is-enabled systemd-journal-remote.socket systemd-journal-remote.service 2>/dev/null)
if echo "$l_enabled_output" | grep -q '^enabled'; then
    l_output2+="\n - systemd-journal-remote.socket und/oder systemd-journal-remote.service sind aktiviert."
else
    l_output+="\n - systemd-journal-remote.socket und systemd-journal-remote.service sind nicht aktiviert."
fi

# Überprüfen, ob systemd-journal-remote.socket und systemd-journal-remote.service nicht aktiv sind
l_active_output=$(systemctl is-active systemd-journal-remote.socket systemd-journal-remote.service 2>/dev/null)
if echo "$l_active_output" | grep -q '^active'; then
    l_output2+="\n - systemd-journal-remote.socket und/oder systemd-journal-remote.service sind aktiv."
else
    l_output+="\n - systemd-journal-remote.socket und systemd-journal-remote.service sind nicht aktiv."
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
