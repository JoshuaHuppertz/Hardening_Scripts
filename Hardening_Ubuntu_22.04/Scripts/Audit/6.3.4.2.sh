#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.2"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob die Datei auditd.conf existiert
if [ -e "/etc/audit/auditd.conf" ]; then
    # Überprüfen, ob das Log-Verzeichnis existiert
    l_audit_log_directory="$(dirname "$(awk -F= '/^\s*log_file\s*/{print $2}' /etc/audit/auditd.conf | xargs)")"
    
    if [ -d "$l_audit_log_directory" ]; then
        # Finden von Dateien, die nicht vom Benutzer "root" besessen werden
        while IFS= read -r -d $'\0' l_file; do
            l_output2+="\n - Datei: \"$l_file\" ist im Besitz von Benutzer: \"$(stat -Lc '%U' "$l_file")\"\n (sollte im Besitz von Benutzer: \"root\" sein)\n"
        done < <(find "$l_audit_log_directory" -maxdepth 1 -type f ! -user root -print0)
        
        # Überprüfen, ob keine Dateien gefunden wurden
        if [ -z "$l_output2" ]; then
            l_output+="\n- Alle Dateien im Verzeichnis \"$l_audit_log_directory\" sind im Besitz von Benutzer: \"root\"\n"
        fi
    else
        l_output2+="\n- ** FAIL **\n - Das Log-Verzeichnis ist nicht in \"/etc/audit/auditd.conf\" festgelegt. Bitte Verzeichnis angeben."
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
