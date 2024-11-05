#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.2.4"

# Ergebnisvariablen initialisieren
l_output=""

# Überprüfen, ob die Gruppe "shadow" existiert und ihre Mitglieder
shadow_group_membership=$(awk -F: '($1=="shadow") {print $NF}' /etc/group)

if [ -n "$shadow_group_membership" ]; then
    l_output+="\n - Die Gruppe \"shadow\" hat Mitglieder: $shadow_group_membership."
fi

# Überprüfen, ob Benutzer die Primärgruppe "shadow" haben
shadow_gid=$(getent group shadow | awk -F: '{print $3}')

if [ -n "$shadow_gid" ]; then
    while IFS= read -r l_user; do
        l_user_check=$(awk -F: '($4 == '"$shadow_gid"') {print " - user: \"" $1 "\" primary group is the shadow group"}' /etc/passwd)
        if [ -n "$l_user_check" ]; then
            l_output+="$l_user_check\n"
        fi
    done < <(getent passwd | cut -d: -f1)  # Alle Benutzer durchlaufen
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - Es wurden keine Benutzer in der Gruppe \"shadow\" gefunden."
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
