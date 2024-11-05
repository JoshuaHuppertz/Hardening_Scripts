#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.2.3"

# Ergebnisvariablen initialisieren
l_output=""

# GIDs in /etc/passwd und /etc/group extrahieren
a_passwd_group_gid=($(awk -F: '{print $4}' /etc/passwd | sort -u))
a_group_gid=($(awk -F: '{print $3}' /etc/group | sort -u))
a_passwd_group_diff=($(printf '%s\n' "${a_group_gid[@]}" "${a_passwd_group_gid[@]}" | sort | uniq -u))

# Überprüfen der GIDs
while IFS= read -r l_gid; do
    l_check_output=$(awk -F: '($4 == '"$l_gid"') {print " - User: \"" $1 "\" has GID: \"" $4 "\" which does not exist in /etc/group"}' /etc/passwd)
    
    # Ergebnis speichern, falls GID nicht existiert
    if [ -n "$l_check_output" ]; then
        l_output+="$l_check_output\n"
    fi
done < <(printf '%s\n' "${a_passwd_group_gid[@]}" "${a_passwd_group_diff[@]}" | sort | uniq -D | uniq)

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - Alle GIDs in /etc/passwd existieren in /etc/group."
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
