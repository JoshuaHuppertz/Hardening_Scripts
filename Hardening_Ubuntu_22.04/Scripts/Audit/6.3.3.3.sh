#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.3"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen der On-Disk-Regeln
SUDO_LOG_FILE=$(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*$//' -e 's/"//g' -e 's|/|\\/|g')

if [ -n "${SUDO_LOG_FILE}" ]; then
    l_disk_rules_output=$(awk "/^ *-w/ \
    && /${SUDO_LOG_FILE}/ \
    && / -p *wa/ \
    && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules)
    
    expected_disk_rules="-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file"

    if [ "$l_disk_rules_output" == "$expected_disk_rules" ]; then
        l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$l_disk_rules_output"
    else
        l_output2+="\n - On-Disk-Regeln sind nicht korrekt konfiguriert:\n$l_disk_rules_output"
    fi
else
    l_output2+="\n - Fehler: Variable 'SUDO_LOG_FILE' ist nicht gesetzt.\n"
fi

# Überprüfen der Running-Regeln
if [ -n "${SUDO_LOG_FILE}" ]; then
    l_running_rules_output=$(auditctl -l | awk "/^ *-w/ \
    && /${SUDO_LOG_FILE}/ \
    && / -p *wa/ \
    && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)")
    
    expected_running_rules="-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file"

    if [ "$l_running_rules_output" == "$expected_running_rules" ]; then
        l_output+="\n - Running-Regeln sind korrekt konfiguriert:\n$l_running_rules_output"
    else
        l_output2+="\n - Running-Regeln sind nicht korrekt konfiguriert:\n$l_running_rules_output"
    fi
else
    l_output2+="\n - Fehler: Variable 'SUDO_LOG_FILE' ist nicht gesetzt.\n"
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
