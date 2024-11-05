#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.1.10"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen der Berechtigungen, UID und GID der Datei /etc/security/opasswd
l_opasswd_file="/etc/security/opasswd"
if [ -e "$l_opasswd_file" ]; then
    l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$l_opasswd_file")
    
    # Überprüfen, ob die Berechtigung 600 oder restriktiver ist
    if [[ "$l_stat_output" =~ Access:\ \(([^/]+)\/ ]]; then
        l_permissions="${BASH_REMATCH[1]}"
        if [ "$l_permissions" -gt 600 ]; then
            l_output2+="\n - Datei: \"$l_opasswd_file\" hat Berechtigung: \"$l_permissions\" (sollte 600 oder restriktiver sein)"
        else
            l_output+="\n - Datei: \"$l_opasswd_file\" hat die erforderlichen Berechtigungen: \"$l_permissions\"."
        fi
    fi
    
    # Überprüfen von UID und GID
    if [[ "$l_stat_output" =~ Uid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_uid="${BASH_REMATCH[1]}"
        l_user="${BASH_REMATCH[2]}"
        if [ "$l_uid" -ne 0 ]; then
            l_output2+="\n - Datei: \"$l_opasswd_file\" hat UID: \"$l_uid\" (sollte 0/root sein)"
        fi
    fi
    
    if [[ "$l_stat_output" =~ Gid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_gid="${BASH_REMATCH[1]}"
        l_group="${BASH_REMATCH[2]}"
        if [ "$l_gid" -ne 0 ]; then
            l_output2+="\n - Datei: \"$l_opasswd_file\" hat GID: \"$l_gid\" (sollte 0/root sein)"
        fi
    fi
else
    l_output+="\n - Datei: \"$l_opasswd_file\" existiert nicht."
fi

# Überprüfen der Berechtigungen, UID und GID der Datei /etc/security/opasswd.old
l_opasswd_old_file="/etc/security/opasswd.old"
if [ -e "$l_opasswd_old_file" ]; then
    l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$l_opasswd_old_file")
    
    # Überprüfen, ob die Berechtigung 600 oder restriktiver ist
    if [[ "$l_stat_output" =~ Access:\ \(([^/]+)\/ ]]; then
        l_permissions="${BASH_REMATCH[1]}"
        if [ "$l_permissions" -gt 600 ]; then
            l_output2+="\n - Datei: \"$l_opasswd_old_file\" hat Berechtigung: \"$l_permissions\" (sollte 600 oder restriktiver sein)"
        else
            l_output+="\n - Datei: \"$l_opasswd_old_file\" hat die erforderlichen Berechtigungen: \"$l_permissions\"."
        fi
    fi
    
    # Überprüfen von UID und GID
    if [[ "$l_stat_output" =~ Uid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_uid="${BASH_REMATCH[1]}"
        l_user="${BASH_REMATCH[2]}"
        if [ "$l_uid" -ne 0 ]; then
            l_output2+="\n - Datei: \"$l_opasswd_old_file\" hat UID: \"$l_uid\" (sollte 0/root sein)"
        fi
    fi
    
    if [[ "$l_stat_output" =~ Gid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_gid="${BASH_REMATCH[1]}"
        l_group="${BASH_REMATCH[2]}"
        if [ "$l_gid" -ne 0 ]; then
            l_output2+="\n - Datei: \"$l_opasswd_old_file\" hat GID: \"$l_gid\" (sollte 0/root sein)"
        fi
    fi
else
    l_output+="\n - Datei: \"$l_opasswd_old_file\" existiert nicht."
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
