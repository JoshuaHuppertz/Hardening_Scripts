#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.1.3"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Funktion zur Überprüfung von Log-Rotationseinstellungen
check_log_rotation() {
    local config_file="$1"
    local param_name="$2"
    
    param_value=$(grep -Po "^\h*$param_name\s*=\s*.*" "$config_file")
    if [ -n "$param_value" ]; then
        l_output="$l_output\n - $param_value"
    else
        l_output2="$l_output2\n - Parameter \"$param_name\" fehlt in \"$config_file\""
    fi
}

# Überprüfen der Hauptkonfigurationsdatei
main_config_file="/etc/systemd/journald.conf"
if [ -f "$main_config_file" ]; then
    check_log_rotation "$main_config_file" "SystemMaxUse"
    check_log_rotation "$main_config_file" "SystemKeepFree"
    check_log_rotation "$main_config_file" "RuntimeMaxUse"
    check_log_rotation "$main_config_file" "RuntimeKeepFree"
    check_log_rotation "$main_config_file" "MaxFileSec"
else
    l_output2="$l_output2\n - Konfigurationsdatei \"$main_config_file\" nicht gefunden."
fi

# Überprüfen der Konfigurationsdateien im Verzeichnis /etc/systemd/journald.conf.d/
conf_dir="/etc/systemd/journald.conf.d/"
if [ -d "$conf_dir" ]; then
    while IFS= read -r -d '' conf_file; do
        l_output="$l_output\nÜberprüfung der Konfigurationsdatei: $conf_file"
        check_log_rotation "$conf_file" "SystemMaxUse"
        check_log_rotation "$conf_file" "SystemKeepFree"
        check_log_rotation "$conf_file" "RuntimeMaxUse"
        check_log_rotation "$conf_file" "RuntimeKeepFree"
        check_log_rotation "$conf_file" "MaxFileSec"
    done < <(find "$conf_dir" -name "*.conf" -print0)
else
    l_output2="$l_output2\n - Verzeichnis \"$conf_dir\" nicht gefunden."
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - * Korrekt konfiguriert * :$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n - * Korrekt konfiguriert * :\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
