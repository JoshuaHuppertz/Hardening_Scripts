#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.1.4"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""
a_parlist=("ForwardToSyslog=yes")
l_systemd_config_file="/etc/systemd/journald.conf"  # Hauptkonfigurationsdatei von systemd

# Funktion zur Überprüfung der Konfigurationsparameter
config_file_parameter_chk() {
    unset A_out
    declare -A A_out  # Überprüfen der Konfigurationseinstellungen

    while read -r l_out; do
        if [ -n "$l_out" ]; then
            if [[ $l_out =~ ^\s*# ]]; then
                l_file="${l_out//# /}"
            else
                l_systemd_parameter="$(awk -F= '{print $1}' <<< "$l_out" | xargs)"
                grep -Piq -- "^\h*$l_systemd_parameter_name\b" <<< "$l_systemd_parameter" && \
                A_out+=(["$l_systemd_parameter"]="$l_file")
            fi
        fi
    done < <(/usr/bin/systemd-analyze cat-config "$l_systemd_config_file" | grep -Pio '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')

    if (( ${#A_out[@]} > 0 )); then  # Ausgaben aus den Dateien bewerten
        while IFS="=" read -r l_systemd_file_parameter_name l_systemd_file_parameter_value; do
            l_systemd_file_parameter_name="${l_systemd_file_parameter_name// /}"
            l_systemd_file_parameter_value="${l_systemd_file_parameter_value// /}"
            if ! grep -Piq "^\h*$l_systemd_parameter_value\b" <<< "$l_systemd_file_parameter_value"; then
                l_output="$l_output\n - \"$l_systemd_file_parameter_name\" is correctly set to \"$l_systemd_file_parameter_value\" in \"$(printf '%s' "${A_out[@]}")\"\n"
            else
                l_output2="$l_output2\n - \"$l_systemd_file_parameter_name\" is incorrectly set to \"$l_systemd_file_parameter_value\" in \"$(printf '%s' "${A_out[@]}")\"\n"
            fi
        done < <(grep -Pio -- "^\h*$l_systemd_parameter_name\h*=\h*\H+" "${A_out[@]}")
    else
        l_output="$l_output\n - \"$l_systemd_parameter_name\" is not set in an included file\n ** Note: \"$l_systemd_parameter_name\" May be set in a file that's ignored by load procedure **\n"
    fi
}

# Überprüfen der Parameter
while IFS="=" read -r l_systemd_parameter_name l_systemd_parameter_value; do
    l_systemd_parameter_name="${l_systemd_parameter_name// /}"
    l_systemd_parameter_value="${l_systemd_parameter_value// /}"
    config_file_parameter_chk
done < <(printf '%s\n' "${a_parlist[@]}")

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Korrekt konfiguriert:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
