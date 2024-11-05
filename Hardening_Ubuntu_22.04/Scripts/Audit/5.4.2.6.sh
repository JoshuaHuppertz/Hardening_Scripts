#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="5.4.2.6"

# Dateien, die geprüft werden
FILES_TO_CHECK=("/root/.bash_profile" "/root/.bashrc")

# Suche nach umask-Einstellungen, die nicht den Anforderungen entsprechen
l_output2=""
for file in "${FILES_TO_CHECK[@]}"; do
    if grep -Psiq -- '^\h*umask\h+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx]{1,3},)?(((g=[rx]?[rx]?w[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))' "$file"; then
        l_output2+=" - In Datei \"$file\" wurde eine unsichere umask-Einstellung gefunden.\n"
    fi
done

# Ergebnis ausgeben und in die passende Datei schreiben
RESULT=""
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - Die umask-Einstellung des root-Benutzers ist korrekt konfiguriert.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
