#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.9"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Audit-Tools
a_audit_tools=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/augenrules"
)

# Überprüfen, ob die Audit-Tools im Besitz des Benutzers "root" sind
for l_audit_tool in "${a_audit_tools[@]}"; do
    if [ -e "$l_audit_tool" ]; then
        l_owner="$(stat -Lc '%U' "$l_audit_tool")"
        if [ "$l_owner" != "root" ]; then
            l_output2+="\n - Audit tool \"$l_audit_tool\" is owned by user: \"$l_owner\" (should be owned by user: \"root\")"
        fi
    else
        l_output2+="\n - Audit tool \"$l_audit_tool\" does not exist."
    fi
done

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - Alle Audit-Tools sind im Besitz von \"root\"."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
