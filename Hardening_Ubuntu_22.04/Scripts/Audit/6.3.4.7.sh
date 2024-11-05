#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.7"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob die Audit-Konfigurationsdateien der Gruppe "root" gehören
while IFS= read -r -d $'\0' l_fname; do
    l_output2+="\n - Datei: \"$l_fname\" gehört nicht zur Gruppe: \"root\""
done < <(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -group root -print0)

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - Alle Audit-Konfigurationsdateien gehören zur Gruppe: \"root\"."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
