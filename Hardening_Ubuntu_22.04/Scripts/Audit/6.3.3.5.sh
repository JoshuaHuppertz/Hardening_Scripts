#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.5"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# On-Disk-Konfiguration überprüfen
on_disk_rules=$(awk '/^ *-a *always,exit/ \
&& / -F *arch=b(32|64)/ \
&& / -S/ \
&& (/sethostname/ || /setdomainname/) \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules)

file_rules=$(awk '/^ *-w/ \
&& (/\/etc\/issue/ || /\/etc\/issue.net/ || /\/etc\/hosts/ || /\/etc\/network/ || /\/etc\/netplan/) \
&& / -p *wa/ \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules)

expected_on_disk_rules="\
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network -p wa -k system-locale
-w /etc/netplan -p wa -k system-locale"

if [[ "$on_disk_rules" == *"$expected_on_disk_rules"* && "$file_rules" == *"$expected_on_disk_rules"* ]]; then
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$on_disk_rules\n$file_rules"
else
    l_output2+="\n - Fehler in den On-Disk-Regeln:\n$on_disk_rules\n$file_rules"
fi

# Running-Konfiguration überprüfen
running_rules=$(auditctl -l | awk '/^ *-a *always,exit/ \
&& / -F *arch=b(32|64)/ \
&& / -S/ \
&& (/sethostname/ || /setdomainname/) \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)')

running_file_rules=$(auditctl -l | awk '/^ *-w/ \
&& (/\/etc\/issue/ || /\/etc\/issue.net/ || /\/etc\/hosts/ || /\/etc\/network/ || /\/etc\/netplan/) \
&& / -p *wa/ \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)')

if [[ "$running_rules" == *"-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale"* && \
      "$running_file_rules" == *"-w /etc/issue -p wa -k system-locale"* ]]; then
    l_output+="\n - Running-Regeln sind korrekt konfiguriert:\n$running_rules\n$running_file_rules"
else
    l_output2+="\n - Fehler in den Running-Regeln:\n$running_rules\n$running_file_rules"
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
