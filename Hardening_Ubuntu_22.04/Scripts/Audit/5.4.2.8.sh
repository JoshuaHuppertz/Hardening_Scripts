#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="5.4.2.8"

# Gültige Shells abrufen
l_valid_shells="^($(awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -r '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Überprüfung aller Nicht-Root-Konten ohne gültige Shells
output=""
while IFS= read -r l_user; do
    # Überprüfen, ob das Konto gesperrt ist
    result=$(passwd -S "$l_user" | awk '$2 !~ /^L/ {print "Account: \"" $1 "\" does not have a valid login shell and is not locked"}')
    if [ -n "$result" ]; then
        output+="$result\n"
    fi
done < <(awk -v pat="$l_valid_shells" -F: '($1 != "root" && $(NF) !~ pat) {print $1}' /etc/passwd)

# Ergebnis ausgeben und in die passende Datei schreiben
RESULT=""
if [ -z "$output" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - Alle Nicht-Root-Konten ohne gültige Login-Shell sind gesperrt.\n"
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
