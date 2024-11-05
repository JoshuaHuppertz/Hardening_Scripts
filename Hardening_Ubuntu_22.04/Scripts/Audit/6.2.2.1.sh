#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.2.1"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Min. UID aus der Konfigurationsdatei holen
l_uidmin="$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"

# Funktion zur Überprüfung der Datei-Berechtigungen und Eigentümerschaft
file_test_chk() {
    l_op2=""
    if [ $(( l_mode & perm_mask )) -gt 0 ]; then
        l_op2="$l_op2\n - Mode: \"$l_mode\" sollte \"$maxperm\" oder restriktiver sein"
    fi
    if [[ ! "$l_user" =~ $l_auser ]]; then
        l_op2="$l_op2\n - Eigentümer: \"$l_user\" sollte sein \"${l_auser//|/ oder }\""
    fi
    if [[ ! "$l_group" =~ $l_agroup ]]; then
        l_op2="$l_op2\n - Gruppeneigentum: \"$l_group\" sollte sein \"${l_agroup//|/ oder }\""
    fi
    [ -n "$l_op2" ] && l_output2="$l_output2\n - Datei: \"$l_fname\" hat:$l_op2\n"
}

# Array zurücksetzen
unset a_file && a_file=() # Array zurücksetzen und initialisieren

# Dateien in /var/log/ mit möglichen Fehlern auflisten
while IFS= read -r -d $'\0' l_file; do
    [ -e "$l_file" ] && a_file+=("$(stat -Lc '%n^%#a^%U^%u^%G^%g' "$l_file")")
done < <(find -L /var/log -type f \( -perm /0137 -o ! -user root -o ! -group root \) -print0)

# Überprüfung der Dateieigenschaften
while IFS="^" read -r l_fname l_mode l_user l_uid l_group l_gid; do
    l_bname="$(basename "$l_fname")"
    case "$l_bname" in
        lastlog | lastlog.* | wtmp | wtmp.* | wtmp-* | btmp | btmp.* | btmp-* | README)
            perm_mask='0113'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="root"
            l_agroup="(root|utmp)"
            file_test_chk
            ;;
        secure | auth.log | syslog | messages)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="(root|syslog)"
            l_agroup="(root|adm)"
            file_test_chk
            ;;
        SSSD | sssd)
            perm_mask='0117'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="(root|SSSD)"
            l_agroup="(root|SSSD)"
            file_test_chk
            ;;
        gdm | gdm3)
            perm_mask='0117'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="root"
            l_agroup="(root|gdm|gdm3)"
            file_test_chk
            ;;
        *.journal | *.journal~)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="root"
            l_agroup="(root|systemd-journal)"
            file_test_chk
            ;;
        *)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="(root|syslog)"
            l_agroup="(root|adm)"
            if [ "$l_uid" -lt "$l_uidmin" ] && [ -z "$(awk -v grp="$l_group" -F: '$1==grp {print $4}' /etc/group)" ]; then
                if [[ ! "$l_user" =~ $l_auser ]]; then
                    l_auser="(root|syslog|$l_user)"
                fi
                if [[ ! "$l_group" =~ $l_agroup ]]; then
                    l_tst=""
                    while l_out3="" read -r l_duid; do
                        [ "$l_duid" -ge "$l_uidmin" ] && l_tst=failed
                    done <<< "$(awk -F: '$4=='"$l_gid"' {print $3}' /etc/passwd)"
                    [ "$l_tst" != "failed" ] && l_agroup="(root|adm|$l_group)"
                fi
            fi
            file_test_chk
            ;;
    esac
done <<< "$(printf '%s\n' "${a_file[@]}")"

# Array zurücksetzen
unset a_file # Array zurücksetzen

# Ergebnisse überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n- Alle Dateien in \"/var/log/\" haben angemessene Berechtigungen und Eigentum\n"
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
