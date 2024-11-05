#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.10"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# On-Disk-Konfiguration überprüfen
on_disk_output=""

# On-Disk-Regeln prüfen
if UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs); then
    if [ -n "${UID_MIN}" ]; then
        if awk "/^ *-a *always,exit/ \
        &&/ -F *arch=b(32|64)/ \
        &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
        &&/ -F *auid>=${UID_MIN}/ \
        &&/ -S/ \
        &&/mount/ \
        &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules; then
            on_disk_output+="OK: On-disk audit rules for mounts found.\n"
        else
            on_disk_output+="Warning: On-disk audit rules for mounts not found.\n"
        fi
    else
        on_disk_output+="ERROR: Variable 'UID_MIN' is unset.\n"
    fi
else
    on_disk_output+="ERROR: Unable to read UID_MIN.\n"
fi

# Überprüfung der On-Disk-Konfigurationsergebnisse
if [[ "$on_disk_output" == *"Warning:"* || "$on_disk_output" == *"ERROR:"* ]]; then
    l_output2+="\n - Fehler in der On-Disk-Konfiguration:\n$on_disk_output"
else
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$on_disk_output"
fi

# Running-Konfiguration überprüfen
running_output=""

# Aktive Audit-Regeln überprüfen
if UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs); then
    if [ -n "${UID_MIN}" ]; then
        if auditctl -l | awk "/^ *-a *always,exit/ \
        &&/ -F *arch=b(32|64)/ \
        &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
        &&/ -F *auid>=${UID_MIN}/ \
        &&/ -S/ \
        &&/mount/ \
        &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)"; then
            running_output+="OK: Running audit rules for mounts found.\n"
        else
            running_output+="Warning: Running audit rules for mounts not found.\n"
        fi
    else
        running_output+="ERROR: Variable 'UID_MIN' is unset.\n"
    fi
else
    running_output+="ERROR: Unable to read UID_MIN.\n"
fi

# Überprüfung der Running-Konfigurationsergebnisse
if [[ "$running_output" == *"Warning:"* || "$running_output" == *"ERROR:"* ]]; then
    l_output2+="\n - Fehler in der Running-Konfiguration:\n$running_output"
else
    l_output+="\n - Running-Regeln sind korrekt konfiguriert:\n$running_output"
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
