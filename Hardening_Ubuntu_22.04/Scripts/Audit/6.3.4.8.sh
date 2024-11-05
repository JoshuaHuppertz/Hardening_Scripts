#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.8"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Berechtigungsmasken
l_perm_mask="0022"

# Maximale Berechtigung
l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )))"

# Audit-Tools
a_audit_tools=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/augenrules"
)

# Überprüfen der Berechtigungen der Audit-Tools
for l_audit_tool in "${a_audit_tools[@]}"; do
    if [ -e "$l_audit_tool" ]; then
        l_mode="$(stat -Lc '%#a' "$l_audit_tool")"
        if [ $(( "$l_mode" & "$l_perm_mask" )) -gt 0 ]; then
            l_output2+="\n - Audit tool \"$l_audit_tool\" is mode: \"$l_mode\" and should be mode: \"$l_maxperm\" or more restrictive"
        else
            l_output+="\n - Audit tool \"$l_audit_tool\" is correctly configured to mode: \"$l_mode\""
        fi
    else
        l_output2+="\n - Audit tool \"$l_audit_tool\" does not exist."
    fi
done

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - * Correctly configured *:$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Reasons for audit failure * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n - * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
