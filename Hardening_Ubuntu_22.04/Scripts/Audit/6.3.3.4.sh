#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.4"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# On-Disk-Konfiguration überprüfen
on_disk_rules=$(awk '/^ *-a *always,exit/ \
&& / -F *arch=b(32|64)/ \
&& / -S/ \
&& (/adjtimex/ || /settimeofday/ || /clock_settime/) \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules)

localtime_rule=$(awk '/^ *-w/ \
&& /\/etc\/localtime/ \
&& / -p *wa/ \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules)

expected_on_disk_rules="\
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change
-w /etc/localtime -p wa -k time-change"

if [[ "$on_disk_rules" == *"$expected_on_disk_rules"* && "$localtime_rule" == *"$expected_on_disk_rules"* ]]; then
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$on_disk_rules\n$localtime_rule"
else
    l_output2+="\n - Fehler in den On-Disk-Regeln:\n$on_disk_rules\n$localtime_rule"
fi

# Running-Konfiguration überprüfen
running_rules=$(auditctl -l | awk '/^ *-a *always,exit/ \
&& / -F *arch=b(32|64)/ \
&& / -S/ \
&& (/adjtimex/ || /settimeofday/ || /clock_settime/) \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)')

running_localtime_rule=$(auditctl -l | awk '/^ *-w/ \
&& /\/etc\/localtime/ \
&& / -p *wa/ \
&& (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)')

if [[ "$running_rules" == *"-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change"* && \
      "$running_localtime_rule" == *"-w /etc/localtime -p wa -k time-change"* ]]; then
    l_output+="\n - Running-Regeln sind korrekt konfiguriert:\n$running_rules\n$running_localtime_rule"
else
    l_output2+="\n - Fehler in den Running-Regeln:\n$running_rules\n$running_localtime_rule"
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
