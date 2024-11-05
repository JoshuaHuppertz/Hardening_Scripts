#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.2"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen der On-Disk-Regeln
l_disk_rules_output=$(awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F *auid!=unset/ || / -F *auid!=-1/ || / -F *auid!=4294967295/) \
&&(/ -C *euid!=uid/ || / -C *uid!=euid/) \
&&/ -S *execve/ \
&&(/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules)

expected_disk_rules="-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation
-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation"

if [ "$l_disk_rules_output" == "$expected_disk_rules" ]; then
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$l_disk_rules_output"
else
    l_output2+="\n - On-Disk-Regeln sind nicht korrekt konfiguriert:\n$l_disk_rules_output"
fi

# Überprüfen der Running-Regeln
l_running_rules_output=$(auditctl -l | awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F *auid!=unset/ || / -F *auid!=-1/ || / -F *auid!=4294967295/) \
&&(/ -C *euid!=uid/ || / -C *uid!=euid/) \
&&/ -S *execve/ \
&&(/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)')

expected_running_rules="-a always,exit -F arch=b64 -S execve -C uid!=euid -F auid!=-1 -F key=user_emulation
-a always,exit -F arch=b32 -S execve -C uid!=euid -F auid!=-1 -F key=user_emulation"

if [ "$l_running_rules_output" == "$expected_running_rules" ]; then
    l_output+="\n - Running-Regeln sind korrekt konfiguriert:\n$l_running_rules_output"
else
    l_output2+="\n - Running-Regeln sind nicht korrekt konfiguriert:\n$l_running_rules_output"
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
