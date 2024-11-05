#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.4"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Berechtigungsmasken
l_perm_mask="0027"

# Überprüfen, ob die Datei auditd.conf existiert
if [ -e "/etc/audit/auditd.conf" ]; then
    # Das Log-Verzeichnis aus der Konfigurationsdatei lesen
    l_audit_log_directory="$(dirname "$(awk -F= '/^\s*log_file\s*/{print $2}' /etc/audit/auditd.conf | xargs)")"

    # Überprüfen, ob das Verzeichnis existiert
    if [ -d "$l_audit_log_directory" ]; then
        l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )) )"
        l_directory_mode="$(stat -Lc '%#a' "$l_audit_log_directory")"

        # Überprüfen, ob die Berechtigungen restriktiver sind
        if [ $(( $l_directory_mode & $l_perm_mask )) -gt 0 ]; then
            l_output2+="\n- ** FAIL **\n - Verzeichnis: \"$l_audit_log_directory\" hat Berechtigung: \"$l_directory_mode\"\n (sollte mindestens \"$l_maxperm\" oder restriktiver sein)\n"
        else
            l_output+="\n- Verzeichnis: \"$l_audit_log_directory\" hat die korrekten Berechtigungen: \"$l_directory_mode\"\n (sollte mindestens \"$l_maxperm\" oder restriktiver sein)\n"
        fi
    else
        l_output2+="\n- ** FAIL **\n - Log-Verzeichnis ist nicht in \"/etc/audit/auditd.conf\" festgelegt. Bitte Verzeichnis angeben."
    fi
else
    l_output2+="\n- ** FAIL **\n - Datei: \"/etc/audit/auditd.conf\" nicht gefunden.\n - ** Überprüfen Sie, ob auditd installiert ist **"
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Erfolgreich konfiguriert:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
