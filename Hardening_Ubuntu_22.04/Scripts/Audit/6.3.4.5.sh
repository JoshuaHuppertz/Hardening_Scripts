#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.5"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Berechtigungsmasken
l_perm_mask="0137"
l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )) )"

# Überprüfen der Konfigurationsdateien
while IFS= read -r -d $'\0' l_fname; do
    l_mode=$(stat -Lc '%#a' "$l_fname")
    if [ $(( "$l_mode" & "$l_perm_mask" )) -gt 0 ]; then
        l_output2+="\n - Datei: \"$l_fname\" hat Berechtigung: \"$l_mode\"\n (sollte mindestens \"$l_maxperm\" oder restriktiver sein)"
    fi
done < <(find /etc/audit/ -type f \( -name "*.conf" -o -name '*.rules' \) -print0)

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - Alle Audit-Konfigurationsdateien haben die erforderlichen Berechtigungen: \"$l_maxperm\" oder restriktiver."
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
