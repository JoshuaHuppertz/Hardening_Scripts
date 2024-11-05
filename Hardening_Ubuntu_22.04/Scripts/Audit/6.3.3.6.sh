#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.6"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# On-Disk-Konfiguration überprüfen
on_disk_output=""

for PARTITION in $(findmnt -n -l -k -it $(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
    for PRIVILEGED in $(find "${PARTITION}" -xdev -perm /6000 -type f); do
        if grep -qr "${PRIVILEGED}" /etc/audit/rules.d; then
            on_disk_output+="OK: '${PRIVILEGED}' found in auditing rules.\n"
        else
            on_disk_output+="Warning: '${PRIVILEGED}' not found in on disk configuration.\n"
        fi
    done
done

# Überprüfung der On-Disk-Konfigurationsergebnisse
if [[ "$on_disk_output" == *"Warning:"* ]]; then
    l_output2+="\n - Fehler in der On-Disk-Konfiguration:\n$on_disk_output"
else
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$on_disk_output"
fi

# Running-Konfiguration überprüfen
running_output=""

RUNNING=$(auditctl -l)

if [ -n "${RUNNING}" ]; then
    for PARTITION in $(findmnt -n -l -k -it $(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
        for PRIVILEGED in $(find "${PARTITION}" -xdev -perm /6000 -type f); do
            if printf -- "${RUNNING}" | grep -q "${PRIVILEGED}"; then
                running_output+="OK: '${PRIVILEGED}' found in auditing rules.\n"
            else
                running_output+="Warning: '${PRIVILEGED}' not found in running configuration.\n"
            fi
        done
    done
else
    running_output="ERROR: Variable 'RUNNING' is unset.\n"
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
