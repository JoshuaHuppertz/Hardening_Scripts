#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.1"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Berechtigungsmasken
l_perm_mask="0137"

# Überprüfen, ob die Datei auditd.conf existiert
if [ -e "/etc/audit/auditd.conf" ]; then
    # Das Log-Verzeichnis aus der Konfigurationsdatei lesen
    l_audit_log_directory="$(dirname "$(awk -F= '/^\s*log_file\s*/{print $2}' /etc/audit/auditd.conf | xargs)")"

    # Überprüfen, ob das Verzeichnis existiert
    if [ -d "$l_audit_log_directory" ]; then
        l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )) )"
        a_files=()

        # Finden der Dateien im Audit-Log-Verzeichnis mit der entsprechenden Berechtigung
        while IFS= read -r -d $'\0' l_file; do
            [ -e "$l_file" ] && a_files+=("$l_file")
        done < <(find "$l_audit_log_directory" -maxdepth 1 -type f -perm /"$l_perm_mask" -print0)

        # Überprüfen, ob Dateien gefunden wurden
        if (( "${#a_files[@]}" > 0 )); then
            for l_file in "${a_files[@]}"; do
                l_file_mode="$(stat -Lc '%#a' "$l_file")"
                l_output2+="\n- ** FAIL **\n - Datei: \"$l_file\" hat Berechtigung: \"$l_file_mode\"\n (sollte mindestens \"$l_maxperm\" oder restriktiver sein)\n"
            done
        else
            l_output+="\n- Alle Dateien in \"$l_audit_log_directory\" haben die erforderlichen Berechtigungen: \"$l_maxperm\" oder restriktiver"
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
