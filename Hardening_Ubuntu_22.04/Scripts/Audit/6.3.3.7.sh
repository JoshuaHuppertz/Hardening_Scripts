#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.7"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# UID_MIN aus der Konfiguration abrufen
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# On-Disk-Konfiguration überprüfen
on_disk_output=""

if [ -n "${UID_MIN}" ]; then
    for ARCH in b64 b32; do
        # Regeln für b64 und b32 überprüfen
        for EXIT_CODE in EACCES EPERM; do
            if awk "/^ *-a *always,exit/ \
            &&/ -F *arch=${ARCH}/ \
            &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
            &&/ -F *auid>=${UID_MIN}/ \
            &&(/ -F *exit=-${EXIT_CODE}/) \
            &&/ -S/ \
            &&/creat/ \
            &&/open/ \
            &&/truncate/ \
            &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules; then
                on_disk_output+="OK: Audit rule for ${ARCH} with exit code ${EXIT_CODE} found.\n"
            else
                on_disk_output+="Warning: Audit rule for ${ARCH} with exit code ${EXIT_CODE} not found.\n"
            fi
        done
    done
else
    on_disk_output="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Überprüfung der On-Disk-Konfigurationsergebnisse
if [[ "$on_disk_output" == *"Warning:"* ]]; then
    l_output2+="\n - Fehler in der On-Disk-Konfiguration:\n$on_disk_output"
else
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$on_disk_output"
fi

# Running-Konfiguration überprüfen
running_output=""

if [ -n "${UID_MIN}" ]; then
    RUNNING=$(auditctl -l)

    if [ -n "${RUNNING}" ]; then
        for ARCH in b64 b32; do
            for EXIT_CODE in EACCES EPERM; do
                if printf -- "${RUNNING}" | awk "/^ *-a *always,exit/ \
                &&/ -F *arch=${ARCH}/ \
                &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
                &&/ -F *auid>=${UID_MIN}/ \
                &&(/ -F *exit=-${EXIT_CODE}/) \
                &&/ -S/ \
                &&/creat/ \
                &&/open/ \
                &&/truncate/ \
                &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)/" ; then
                    running_output+="OK: Running rule for ${ARCH} with exit code ${EXIT_CODE} found.\n"
                else
                    running_output+="Warning: Running rule for ${ARCH} with exit code ${EXIT_CODE} not found.\n"
                fi
            done
        done
    else
        running_output="ERROR: Variable 'RUNNING' is unset.\n"
    fi
else
    running_output="ERROR: Variable 'UID_MIN' is unset.\n"
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
