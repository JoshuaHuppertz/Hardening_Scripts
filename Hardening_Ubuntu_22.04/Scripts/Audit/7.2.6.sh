#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.2.6"

# Ergebnisvariablen initialisieren
l_output=""

# Überprüfen auf doppelte GIDs
while read -r l_count l_gid; do
    if [ "$l_count" -gt 1 ]; then
        l_output+="\n - Duplicate GID: \"$l_gid\" Groups: \"$(awk -F: '($3 == n) { print $1 }' n="$l_gid" /etc/group | xargs)\""
    fi
done < <(cut -f3 -d":" /etc/group | sort -n | uniq -c)

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - Es wurden keine doppelten GIDs gefunden."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
