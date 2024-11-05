#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="5.4.2.7"

# Gültige Shells abrufen
l_valid_shells="^($(awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -r '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Systemkonten ohne gültige Shells überprüfen
output=$(awk -v pat="$l_valid_shells" -F: '($1!~/^(root|halt|sync|shutdown|nfsnobody)$/ && ($3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' || $3 == 65534) && $(NF) ~ pat) {print "Service account: \"" $1 "\" has a valid shell: " $7}' /etc/passwd)

# Ergebnis ausgeben und in die passende Datei schreiben
RESULT=""
if [ -z "$output" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - Alle Systemkonten haben keine gültige Login-Shell.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :\n$output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
