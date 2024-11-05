#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="5.4.3.3"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Funktion zur Überprüfung der umask in einer Datei
file_umask_chk() {
    if grep -Psiq -- '^\h*umask\h+(0?[0-7][2-7]7|u(=[rwx]{0,3}),g=([rx]{0,2}),o=)(\h*#.*)?$' "$l_file"; then
        l_output="$l_output\n - umask ist korrekt in \"$l_file\" gesetzt"
    elif grep -Psiq -- '^\h*umask\h+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx]{1,3},)?(((g=[rx]?[rx]?w[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))' "$l_file"; then
        l_output2="$l_output2\n - umask ist inkorrekt in \"$l_file\" gesetzt"
    fi
}

# Überprüfen der umask in den Skripten im /etc/profile.d/
while IFS= read -r -d $'\0' l_file; do
    file_umask_chk
done < <(find /etc/profile.d/ -type f -name '*.sh' -print0)

# Überprüfen in weiteren Dateien
[ -z "$l_output" ] && l_file="/etc/profile" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/bashrc" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/bash.bashrc" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/pam.d/postlogin"

if [ -z "$l_output" ]; then
    if grep -Psiq -- '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(0?[0-7][2-7]7)\b' "$l_file"; then
        l_output="$l_output\n - umask ist korrekt in \"$l_file\" gesetzt"
    elif grep -Psiq '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b))' "$l_file"; then
        l_output2="$l_output2\n - umask ist inkorrekt in \"$l_file\" gesetzt"
    fi
fi

[ -z "$l_output" ] && l_file="/etc/login.defs" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/default/login" && file_umask_chk

[[ -z "$l_output" && -z "$l_output2" ]] && l_output2="$l_output2\n - umask ist nicht gesetzt"

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n *** PASS ***\n - * Korrekt konfiguriert *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Gründe für das Fehlschlagen der Prüfung * :\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- * Korrekt konfiguriert *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
