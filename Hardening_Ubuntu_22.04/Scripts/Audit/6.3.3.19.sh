#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.3.3.19"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# On-Disk-Konfiguration überprüfen
on_disk_output=""

# On-Disk-Regeln für Kernel-Module prüfen
if awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F auid!=unset/||/ -F auid!=-1/||/ -F auid!=4294967295/) \
&&/ -S/ \
&&(/init_module/ \
||/finit_module/ \
||/delete_module/) \
&&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules; then
    on_disk_output+="OK: On-disk audit rules for kernel modules found.\n"
else
    on_disk_output+="Warning: On-disk audit rules for kernel modules not found.\n"
fi

# UID_MIN für kmod prüfen
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
if [ -n "${UID_MIN}" ]; then
    if awk "/^ *-a *always,exit/ \
    &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
    &&/ -F *auid>=${UID_MIN}/ \
    &&/ -F *perm=x/ \
    &&/ -F *path=\/usr\/bin\/kmod/ \
    &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules; then
        on_disk_output+="OK: On-disk audit rules for /usr/bin/kmod found.\n"
    else
        on_disk_output+="Warning: On-disk audit rules for /usr/bin/kmod not found.\n"
    fi
else
    on_disk_output+="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Überprüfung der On-Disk-Konfigurationsergebnisse
if [[ "$on_disk_output" == *"Warning:"* || "$on_disk_output" == *"ERROR:"* ]]; then
    l_output2+="\n - Fehler in der On-Disk-Konfiguration:\n$on_disk_output"
else
    l_output+="\n - On-Disk-Regeln sind korrekt konfiguriert:\n$on_disk_output"
fi

# Running-Konfiguration überprüfen
running_output=""

# Aktive Audit-Regeln für Kernel-Module überprüfen
if auditctl -l | awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F auid!=unset/||/ -F auid!=-1/||/ -F auid!=4294967295/) \
&&/ -S/ \
&&(/init_module/ \
||/finit_module/ \
||/delete_module/) \
&&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)'; then
    running_output+="OK: Running audit rules for kernel modules found.\n"
else
    running_output+="Warning: Running audit rules for kernel modules not found.\n"
fi

# UID_MIN für kmod überprüfen
if [ -n "${UID_MIN}" ]; then
    if auditctl -l | awk "/^ *-a *always,exit/ \
    &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
    &&/ -F *auid>=${UID_MIN}/ \
    &&/ -F *perm=x/ \
    &&/ -F *path=\/usr\/bin\/kmod/ \
    &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)"; then
        running_output+="OK: Running audit rules for /usr/bin/kmod found.\n"
    else
        running_output+="Warning: Running audit rules for /usr/bin/kmod not found.\n"
    fi
else
    running_output+="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Überprüfung der Running-Konfigurationsergebnisse
if [[ "$running_output" == *"Warning:"* || "$running_output" == *"ERROR:"* ]]; then
    l_output2+="\n - Fehler in der Running-Konfiguration:\n$running_output"
else
    l_output+="\n - Running-Regeln sind korrekt konfiguriert:\n$running_output"
fi

# Symlink-Überprüfung
symlink_output=""
S_LINKS=$(ls -l /usr/sbin/lsmod /usr/sbin/rmmod /usr/sbin/insmod /usr/sbin/modinfo /usr/sbin/modprobe /usr/sbin/depmod | grep -vE " -> (\.\./)?bin/kmod" || true)
if [[ "${S_LINKS}" != "" ]]; then
    symlink_output="Issue with symlinks:\n${S_LINKS}\n"
else
    symlink_output="OK: All symlinks are correctly pointing to /usr/bin/kmod.\n"
fi

# Überprüfung der Symlink-Ergebnisse
if [[ "$symlink_output" == *"Issue with symlinks:"* ]]; then
    l_output2+="\n - Fehler in den Symlinks:\n$symlink_output"
else
    l_output+="\n - Symlinks sind korrekt konfiguriert:\n$symlink_output"
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
