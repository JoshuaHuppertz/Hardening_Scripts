#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="7.2.9"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""
l_heout2=""
l_hoout2=""
l_haout2=""

# Gültige Shells definieren
l_valid_shells="^($(awk -F/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Array für Benutzer und Home-Verzeichnisse initialisieren
unset a_uarr && a_uarr=() 
while read -r l_epu l_eph; do 
    a_uarr+=("$l_epu $l_eph")
done <<< "$(awk -v pat="$l_valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)"

l_asize="${#a_uarr[@]}" # Anzahl der Benutzer prüfen
if [ "$l_asize" -gt "10000" ]; then
    echo -e "\n ** INFO **\n - \"$l_asize\" Local interactive users found on the system\n - This may be a long running check\n"
fi

# Überprüfen der Home-Verzeichnisse
while read -r l_user l_home; do
    if [ -d "$l_home" ]; then
        l_mask='0027'
        l_max="$(printf '%o' $((0777 & ~$l_mask)))"
        while read -r l_own l_mode; do
            [ "$l_user" != "$l_own" ] && l_hoout2="$l_hoout2\n - User: \"$l_user\" Home \"$l_home\" is owned by: \"$l_own\""
            if [ $(( l_mode & l_mask )) -gt 0 ]; then
                l_haout2="$l_haout2\n - User: \"$l_user\" Home \"$l_home\" is mode: \"$l_mode\" should be mode: \"$l_max\" or more restrictive"
            fi
        done <<< "$(stat -Lc '%U %#a' "$l_home")"
    else
        l_heout2="$l_heout2\n - User: \"$l_user\" Home \"$l_home\" doesn't exist"
    fi
done <<< "$(printf '%s\n' "${a_uarr[@]}")"

# Zusammenfassen der Ergebnisse
[ -z "$l_heout2" ] && l_output="$l_output\n - Home directories exist" || l_output2="$l_output2$l_heout2"
[ -z "$l_hoout2" ] && l_output="$l_output\n - Own their home directory" || l_output2="$l_output2$l_hoout2"
[ -z "$l_haout2" ] && l_output="$l_output\n - Home directories are mode: \"$l_max\" or more restrictive" || l_output2="$l_output2$l_haout2"

# Audit-Ergebnisse ausgeben
if [ -n "$l_output" ]; then
    l_output=" - All local interactive users:$l_output"
fi

# Ergebnisformatierung für die Ausgabe
if [ -z "$l_output2" ]; then 
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n - * Correctly configured *:\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - * Reasons for audit failure *:\n$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optional: Ergebnis in der Konsole ausgeben
echo -e "$RESULT"
