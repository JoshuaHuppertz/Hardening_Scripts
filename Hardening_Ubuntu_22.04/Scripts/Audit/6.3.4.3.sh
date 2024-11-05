#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.4.3"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob die Datei auditd.conf existiert
if [ -e "/etc/audit/auditd.conf" ]; then
    # Überprüfen, ob der log_group Parameter auf adm oder root gesetzt ist
    log_group_output=$(grep -Piws -- '^\h*log_group\h*=\h*\H+\b' /etc/audit/auditd.conf | grep -Pvi -- '(adm)')
    
    # Überprüfen, ob der Befehl eine Ausgabe erzeugt
    if [ -n "$log_group_output" ]; then
        l_output2+="\n- ** FAIL **\n - Der log_group Parameter ist nicht korrekt gesetzt.\n"
    fi

    # Das Log-Verzeichnis aus der Konfigurationsdatei lesen
    l_fpath="$(dirname "$(awk -F "=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf | xargs)")"
    
    # Überprüfen, ob das Verzeichnis existiert
    if [ -d "$l_fpath" ]; then
        # Finden von Dateien, die nicht die Gruppen "root" oder "adm" besitzen
        while IFS= read -r -d $'\0' l_file; do
            l_output2+="\n - Datei: \"$l_file\" gehört nicht zur Gruppe \"root\" oder \"adm\"\n"
        done < <(find -L "$l_fpath" -not -path "$l_fpath"/lost+found -type f \( ! -group root -a ! -group adm \) -print0)
        
        # Überprüfen, ob keine Dateien gefunden wurden
        if [ -z "$l_output2" ]; then
            l_output+="\n- Alle Dateien im Verzeichnis \"$l_fpath\" gehören zur Gruppe \"root\" oder \"adm\"\n"
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
